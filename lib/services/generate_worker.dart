import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart' show Color;
import 'package:image/image.dart' as img;

import '../data/platform_specs.dart';
import 'generate_job.dart';
import 'image_service.dart';

/// Entry point for the background isolate (spawned via `Isolate.spawn` in
/// `generate_controller.dart`). Must be a top-level function.
///
/// Protocol: on start, sends its own SendPort back to the caller (the
/// standard Dart handshake). The caller then sends a `GenerateJob.toMap()`
/// job. While processing, this sends `{'type': 'step', 'index': int}`
/// messages as each phase completes, then either
/// `{'type': 'done', 'bytes': Uint8List}` or
/// `{'type': 'error', 'message': String}`.
void generateWorkerEntry(SendPort mainSendPort) {
  final workerReceive = ReceivePort();
  mainSendPort.send(workerReceive.sendPort);
  workerReceive.listen((message) {
    if (message is Map) {
      _runJob(GenerateJob.fromMap(message), mainSendPort);
    }
  });
}

void _runJob(GenerateJob job, SendPort mainSendPort) {
  try {
    var stepIdx = 0;

    mainSendPort.send({'type': 'step', 'index': stepIdx++}); // Loading image
    final decoded = ImageService.decode(job.imageBytes);
    if (decoded == null) {
      mainSendPort.send({'type': 'error', 'message': 'could not decode image'});
      return;
    }

    mainSendPort.send({'type': 'step', 'index': stepIdx++}); // Processing image
    img.Image baseImg = ImageService.resizeImage(decoded, 1024);

    if (job.removeBg) {
      mainSendPort.send({'type': 'step', 'index': stepIdx++}); // Removing background
      baseImg = ImageService.removeBackground(baseImg);
    }

    final archive = Archive();
    for (final platform in job.platforms) {
      mainSendPort.send({'type': 'step', 'index': stepIdx++}); // Generating <platform> assets
      buildPlatformAssets(archive, baseImg, platform, job.genAdaptive);
    }

    if (job.genNotif) {
      mainSendPort.send({'type': 'step', 'index': stepIdx++}); // Creating notification icons
      addNotificationIcons(archive, baseImg, job);
    }

    archive.addFile(ArchiveFile.string('README.md', generateReadme(job)));

    mainSendPort.send({'type': 'step', 'index': stepIdx++}); // Building ZIP archive
    final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive) ?? []);

    mainSendPort.send({'type': 'done', 'bytes': zipBytes});
  } catch (err) {
    mainSendPort.send({'type': 'error', 'message': '$err'});
  }
}

// ---------------------------------------------------------------------
// Archive-building logic. Pure functions (no isolate/Flutter-UI
// dependencies beyond the plain `Color` value type) — shared by both
// the isolate entry point above and generate_controller.dart's
// synchronous main-isolate fallback, so there's exactly one
// implementation of "what goes in the ZIP" regardless of which isolate
// runs it.
// ---------------------------------------------------------------------

void _addFile(Archive archive, String path, List<int> bytes) {
  archive.addFile(ArchiveFile(path, bytes.length, bytes));
}

void buildPlatformAssets(Archive archive, img.Image baseImg, String platform, bool genAdaptive) {
  switch (platform) {
    case 'android':
      _addAndroid(archive, baseImg, genAdaptive);
      break;
    case 'ios':
      _addIos(archive, baseImg);
      break;
    case 'web':
      _addWeb(archive, baseImg);
      break;
    case 'linux':
      _addLinux(archive, baseImg);
      break;
    case 'windows':
      _addWindows(archive, baseImg);
      break;
    case 'macos':
      _addMacos(archive, baseImg);
      break;
  }
}

void _addAndroid(Archive archive, img.Image baseImg, bool genAdaptive) {
  const base = 'android/app/src/main/res';

  kAndroidMipmapSizes.forEach((folder, sizes) {
    final launcherSize = sizes[0];
    final foregroundSize = sizes[1];

    final launcher = ImageService.resizeImage(baseImg, launcherSize, bgColor: const Color(0xFFFFFFFF));
    _addFile(archive, '$base/$folder/ic_launcher.png', ImageService.encodePng(launcher));

    final round = ImageService.resizeImage(baseImg, launcherSize,
        bgColor: const Color(0xFFFFFFFF), rounded: true);
    _addFile(archive, '$base/$folder/ic_launcher_round.png', ImageService.encodePng(round));

    if (genAdaptive) {
      final fg = ImageService.resizeImage(baseImg, foregroundSize);
      _addFile(archive, '$base/$folder/ic_launcher_foreground.png', ImageService.encodePng(fg));

      if (folder == 'mipmap-mdpi') {
        final bg = img.Image(width: foregroundSize, height: foregroundSize, numChannels: 4);
        img.fill(bg, color: img.ColorRgba8(255, 255, 255, 255));
        _addFile(archive, '$base/$folder/ic_launcher_background.png', ImageService.encodePng(bg));
      }
    }
  });

  final playStore = ImageService.resizeImage(baseImg, 512, bgColor: const Color(0xFFFFFFFF));
  _addFile(archive, 'android/play_store_icon.png', ImageService.encodePng(playStore));

  if (genAdaptive) {
    const adaptiveXml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>''';
    archive.addFile(ArchiveFile.string('$base/mipmap-anydpi-v26/ic_launcher.xml', adaptiveXml));
    archive.addFile(ArchiveFile.string('$base/mipmap-anydpi-v26/ic_launcher_round.xml', adaptiveXml));
  }
}

void _addIos(Archive archive, img.Image baseImg) {
  const base = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  for (final spec in kIosIconSizes) {
    final canvas = ImageService.resizeImage(baseImg, spec.size, bgColor: const Color(0xFFFFFFFF));
    _addFile(archive, '$base/${spec.name}', ImageService.encodePng(canvas));
  }

  final images = kIosIconSizes.map((s) {
    final scale = s.name.contains('@2x') ? '2x' : (s.name.contains('@3x') ? '3x' : '1x');
    final sizeMatch = RegExp(r'\d+(\.\d+)?x\d+(\.\d+)?').firstMatch(s.name);
    return {
      'filename': s.name,
      'idiom': s.size >= 1024 ? 'ios-marketing' : 'iphone',
      'scale': scale,
      'size': sizeMatch?.group(0) ?? '60x60',
    };
  }).toList();

  final contents = _jsonEncodePretty({
    'images': images,
    'info': {'author': 'flutter_logo_generator', 'version': 1},
  });
  archive.addFile(ArchiveFile.string('$base/Contents.json', contents));
}

void _addWeb(Archive archive, img.Image baseImg) {
  final favicon = ImageService.resizeImage(baseImg, 16);
  _addFile(archive, 'web/favicon.png', ImageService.encodePng(favicon));

  final icon192 = ImageService.resizeImage(baseImg, 192);
  _addFile(archive, 'web/icons/Icon-192.png', ImageService.encodePng(icon192));

  final icon512 = ImageService.resizeImage(baseImg, 512);
  _addFile(archive, 'web/icons/Icon-512.png', ImageService.encodePng(icon512));

  final maskable192 =
      ImageService.resizeImage(baseImg, 192, maskable: true, bgColor: const Color(0xFFFFFFFF));
  _addFile(archive, 'web/icons/Icon-maskable-192.png', ImageService.encodePng(maskable192));

  final maskable512 =
      ImageService.resizeImage(baseImg, 512, maskable: true, bgColor: const Color(0xFFFFFFFF));
  _addFile(archive, 'web/icons/Icon-maskable-512.png', ImageService.encodePng(maskable512));
}

void _addLinux(Archive archive, img.Image baseImg) {
  final app48 = ImageService.resizeImage(baseImg, 48);
  _addFile(archive, 'linux/my_application.png', ImageService.encodePng(app48));

  final app64 = ImageService.resizeImage(baseImg, 64);
  _addFile(archive, 'linux/my_application@2x.png', ImageService.encodePng(app64));

  final app128 = ImageService.resizeImage(baseImg, 128);
  _addFile(archive, 'linux/128x128/my_application.png', ImageService.encodePng(app128));

  final app256 = ImageService.resizeImage(baseImg, 256);
  _addFile(archive, 'linux/256x256/my_application.png', ImageService.encodePng(app256));
}

void _addWindows(Archive archive, img.Image baseImg) {
  final app256 = ImageService.resizeImage(baseImg, 256);
  _addFile(archive, 'windows/runner/resources/app_icon.png', ImageService.encodePng(app256));

  final ico = ImageService.generateIco(baseImg, const [16, 32, 48, 256]);
  _addFile(archive, 'windows/runner/resources/app_icon.ico', ico);
}

void _addMacos(Archive archive, img.Image baseImg) {
  const base = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';
  for (final size in kMacIconSizes) {
    final canvas = ImageService.resizeImage(baseImg, size, bgColor: const Color(0xFFFFFFFF));
    _addFile(archive, '$base/app_icon_$size.png', ImageService.encodePng(canvas));
  }

  final images = kMacIconSizes.map((s) => {
        'filename': 'app_icon_$s.png',
        'idiom': 'mac',
        'scale': '1x',
        'size': '${s ~/ 2}x${s ~/ 2}',
      }).toList();

  final contents = _jsonEncodePretty({
    'images': images,
    'info': {'author': 'flutter_logo_generator', 'version': 1},
  });
  archive.addFile(ArchiveFile.string('$base/Contents.json', contents));
}

void addNotificationIcons(Archive archive, img.Image baseImg, GenerateJob job) {
  const size = 96;

  if (job.theme == 'both' || job.theme == 'light') {
    final light = ImageService.generateNotificationIcon(baseImg, size, Color(job.lightBg), Color(job.lightFg));
    _addFile(archive, 'notification/notification_icon_light.png', ImageService.encodePng(light));

    if (job.platforms.contains('android')) {
      kAndroidNotifDrawableSizes.forEach((folder, drawSize) {
        final c = ImageService.generateNotificationIcon(
            baseImg, drawSize, Color(job.lightBg), Color(job.lightFg));
        _addFile(archive, 'android/app/src/main/res/$folder/ic_notification.png', ImageService.encodePng(c));
      });
    }
  }

  if (job.theme == 'both' || job.theme == 'dark') {
    final dark = ImageService.generateNotificationIcon(baseImg, size, Color(job.darkBg), Color(job.darkFg));
    _addFile(archive, 'notification/notification_icon_dark.png', ImageService.encodePng(dark));
  }
}

String generateReadme(GenerateJob job) {
  final platforms = job.platforms.join(', ');
  final buffer = StringBuffer();
  buffer.writeln('# Flutter Assets — Generated by Flutter Logo Generator');
  buffer.writeln();
  buffer.writeln('## Platforms: $platforms');
  buffer.writeln();
  buffer.writeln('## How to use');
  buffer.writeln();
  buffer.writeln('### Android');
  buffer.writeln("Copy the contents of `android/` into your Flutter project's `android/` directory.");
  buffer.writeln('The `play_store_icon.png` goes in your Play Store listing.');
  if (job.genAdaptive) {
    buffer.writeln('Adaptive icons are included for API 26+ (Android 8+).');
  }
  buffer.writeln();
  buffer.writeln('### iOS');
  buffer.writeln('Copy `ios/Runner/Assets.xcassets/AppIcon.appiconset/` into your project.');
  buffer.writeln('Replace the existing AppIcon.appiconset folder.');
  buffer.writeln();
  buffer.writeln('### Web');
  buffer.writeln("Copy the contents of `web/` into your Flutter project's `web/` folder.");
  buffer.writeln('Make sure your `manifest.json` references the icon paths correctly.');
  buffer.writeln();
  buffer.writeln('### Linux');
  buffer.writeln("Copy the contents of `linux/` into your project's `linux/` folder.");
  buffer.writeln();
  buffer.writeln('### Windows');
  buffer.writeln('Copy `windows/runner/resources/app_icon.ico` and `app_icon.png` to your project.');
  buffer.writeln();
  buffer.writeln('### macOS');
  buffer.writeln('Replace the AppIcon.appiconset folder in your macOS project.');
  buffer.writeln();
  buffer.writeln('### Notification Icons');
  buffer.writeln('The `notification/` folder contains icons for push notifications.');
  if (job.genNotif && job.platforms.contains('android')) {
    buffer.writeln(
        'Android notification icons are also in `android/app/src/main/res/drawable-*/ic_notification.png`.');
  }
  buffer.writeln();
  buffer.writeln('## Notes');
  buffer.writeln('- All processing was done locally in your browser');
  buffer.writeln('- No images were uploaded to any server');
  buffer.writeln('- Generated: ${DateTime.now().toUtc().toIso8601String()}');
  return buffer.toString();
}

String _jsonEncodePretty(Map<String, dynamic> data) {
  return const JsonEncoder.withIndent('  ').convert(data);
}
