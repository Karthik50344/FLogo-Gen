import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:image/image.dart' as img;

import '../models/app_state.dart';
import 'download_helper.dart';
import 'generate_job.dart';
import 'generate_worker.dart';
import 'image_service.dart';

/// Result of a generate() call, used to drive the toast message.
class GenerateResult {
  final bool success;
  final String message;
  const GenerateResult(this.success, this.message);
}

class GenerateController {
  GenerateController._();

  static Future<GenerateResult> generate(AppState state) async {
    if (!state.hasImage) {
      return const GenerateResult(false, 'Please upload a logo first');
    }
    if (state.platforms.isEmpty) {
      return const GenerateResult(false, 'Select at least one platform');
    }

    final job = GenerateJob(
      imageBytes: state.imageBytes!,
      platforms: state.platforms.toList(),
      removeBg: state.removeBg,
      genNotif: state.genNotif,
      genAdaptive: state.genAdaptive,
      theme: state.theme,
      lightBg: state.lightBg.value,
      lightFg: state.lightFg.value,
      darkBg: state.darkBg.value,
      darkFg: state.darkFg.value,
    );

    // "Finalizing download" isn't a worker step (the download itself has
    // to happen back on the main isolate — a Web Worker can't touch the
    // DOM), so it's appended here rather than in GenerateJob.stepLabels.
    final steps = [...job.stepLabels, 'Finalizing download'];
    state.startLoading(steps);
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      Uint8List zipBytes;
      try {
        // Preferred path: all the heavy resizing/compositing/ZIP work
        // happens on a background isolate (a Web Worker under Flutter
        // Web), so the UI thread — and this loader's own spinner
        // animation — never blocks, no matter how large the image or
        // how many platforms are selected.
        zipBytes = await _runInBackgroundIsolate(job, state);
      } catch (_) {
        // Fallback for environments where Isolate.spawn isn't available
        // (older SDKs, unusual embedders): identical computation, run
        // synchronously on the main isolate like the original
        // implementation. Slower and the UI will visibly pause during
        // the heavy steps, but still correct.
        zipBytes = await _runOnMainIsolate(job, state);
      }

      await state.setStep(steps.length - 1); // Finalizing download
      DownloadHelper.downloadBytes(zipBytes, 'flutter_assets.zip');

      await Future.delayed(const Duration(milliseconds: 300));
      state.stopLoading();
      state.resetAfterGenerate();
      return const GenerateResult(true, 'Assets generated and downloaded!');
    } catch (err) {
      state.stopLoading();
      return GenerateResult(false, 'Error: $err');
    }
  }

  /// Spawns generate_worker.dart's isolate entry point, hands it the job,
  /// and relays its `{'type': 'step', ...}` progress messages into
  /// [state.setStep] as they arrive — the worker keeps computing on its
  /// own isolate the entire time, so these updates never block it.
  static Future<Uint8List> _runInBackgroundIsolate(GenerateJob job, AppState state) async {
    final mainReceive = ReceivePort();
    final isolate = await Isolate.spawn(generateWorkerEntry, mainReceive.sendPort);

    final completer = Completer<Uint8List>();
    SendPort? workerSendPort;
    late final StreamSubscription sub;

    sub = mainReceive.listen((message) {
      if (message is SendPort) {
        workerSendPort = message;
        workerSendPort!.send(job.toMap());
        return;
      }
      if (message is Map) {
        switch (message['type']) {
          case 'step':
            state.setStep(message['index'] as int);
            break;
          case 'done':
            if (!completer.isCompleted) {
              completer.complete(message['bytes'] as Uint8List);
            }
            break;
          case 'error':
            if (!completer.isCompleted) {
              completer.completeError(message['message'] as String);
            }
            break;
        }
      }
    });

    try {
      return await completer.future;
    } finally {
      await sub.cancel();
      mainReceive.close();
      isolate.kill(priority: Isolate.immediate);
    }
  }

  /// Synchronous fallback: identical computation to generate_worker.dart,
  /// run directly on the calling (main) isolate. Only used if spawning a
  /// background isolate throws.
  static Future<Uint8List> _runOnMainIsolate(GenerateJob job, AppState state) async {
    var stepIdx = 0;

    await state.setStep(stepIdx++);
    final decoded = ImageService.decode(job.imageBytes);
    if (decoded == null) {
      throw 'could not decode image';
    }

    await state.setStep(stepIdx++);
    img.Image baseImg = ImageService.resizeImage(decoded, 1024);

    if (job.removeBg) {
      await state.setStep(stepIdx++);
      baseImg = ImageService.removeBackground(baseImg);
    }

    final archive = Archive();
    for (final platform in job.platforms) {
      await state.setStep(stepIdx++);
      buildPlatformAssets(archive, baseImg, platform, job.genAdaptive);
    }

    if (job.genNotif) {
      await state.setStep(stepIdx++);
      addNotificationIcons(archive, baseImg, job);
    }

    archive.addFile(ArchiveFile.string('README.md', generateReadme(job)));

    await state.setStep(stepIdx++); // Building ZIP archive
    return Uint8List.fromList(ZipEncoder().encode(archive) ?? []);
  }
}
