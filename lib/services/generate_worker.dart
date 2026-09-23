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

// NOTE ON LAYOUT: the ZIP is a *flat, browsable* handoff — one capitalised
// folder per selected platform (Android/, iOS/, Web/, ...) containing just
// the generated assets, not the deep `android/app/src/main/res/...`-style
// path a Flutter project expects on disk. Store-listing icons (Play Store,
// App Store) sit at the ZIP root next to README.md, not inside a platform
// folder, since they aren't part of the app bundle itself. README.md
// spells out exactly where each file goes. Only the selected platforms'
// folders are ever added to the archive.

void _addAndroid(Archive archive, img.Image baseImg, bool genAdaptive) {
  const base = 'Android';

  kAndroidMipmapSizes.forEach((folder, sizes) {
    // folder is e.g. 'mipmap-xhdpi' — used verbatim as the subfolder name.
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

  if (genAdaptive) {
    const adaptiveXml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>''';
    archive.addFile(ArchiveFile.string('$base/mipmap-anydpi-v26/ic_launcher.xml', adaptiveXml));
    archive.addFile(ArchiveFile.string('$base/mipmap-anydpi-v26/ic_launcher_round.xml', adaptiveXml));
  }

  // Play Store listing icon — not part of the app bundle, so it sits at
  // the ZIP root rather than inside Android/.
  final playStore = ImageService.resizeImage(baseImg, 512, bgColor: const Color(0xFFFFFFFF));
  _addFile(archive, 'play_store_icon.png', ImageService.encodePng(playStore));
}

void _addIos(Archive archive, img.Image baseImg) {
  const base = 'iOS';
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

  // App Store listing icon (1024×1024, fully opaque) — not part of the
  // app bundle, so it sits at the ZIP root rather than inside iOS/.
  final appStore = ImageService.resizeImage(baseImg, 1024, bgColor: const Color(0xFFFFFFFF));
  _addFile(archive, 'app_store_icon.png', ImageService.encodePng(appStore));
}

void _addWeb(Archive archive, img.Image baseImg) {
  const base = 'Web';

  final favicon16 = ImageService.resizeImage(baseImg, 16);
  _addFile(archive, '$base/favicon.png', ImageService.encodePng(favicon16));

  final faviconIco = ImageService.generateIco(baseImg, const [16, 32, 48]);
  _addFile(archive, '$base/favicon.ico', faviconIco);

  final icon192 = ImageService.resizeImage(baseImg, 192);
  _addFile(archive, '$base/icons/Icon-192.png', ImageService.encodePng(icon192));

  final icon512 = ImageService.resizeImage(baseImg, 512);
  _addFile(archive, '$base/icons/Icon-512.png', ImageService.encodePng(icon512));

  final maskable192 =
      ImageService.resizeImage(baseImg, 192, maskable: true, bgColor: const Color(0xFFFFFFFF));
  _addFile(archive, '$base/icons/Icon-maskable-192.png', ImageService.encodePng(maskable192));

  final maskable512 =
      ImageService.resizeImage(baseImg, 512, maskable: true, bgColor: const Color(0xFFFFFFFF));
  _addFile(archive, '$base/icons/Icon-maskable-512.png', ImageService.encodePng(maskable512));
}

void _addLinux(Archive archive, img.Image baseImg) {
  const base = 'Linux';
  final app48 = ImageService.resizeImage(baseImg, 48);
  _addFile(archive, '$base/my_application.png', ImageService.encodePng(app48));

  final app64 = ImageService.resizeImage(baseImg, 64);
  _addFile(archive, '$base/my_application@2x.png', ImageService.encodePng(app64));

  final app128 = ImageService.resizeImage(baseImg, 128);
  _addFile(archive, '$base/my_application_128.png', ImageService.encodePng(app128));

  final app256 = ImageService.resizeImage(baseImg, 256);
  _addFile(archive, '$base/my_application_256.png', ImageService.encodePng(app256));
}

void _addWindows(Archive archive, img.Image baseImg) {
  const base = 'Windows';
  final app256 = ImageService.resizeImage(baseImg, 256);
  _addFile(archive, '$base/app_icon.png', ImageService.encodePng(app256));

  final ico = ImageService.generateIco(baseImg, const [16, 32, 48, 256]);
  _addFile(archive, '$base/app_icon.ico', ico);
}

void _addMacos(Archive archive, img.Image baseImg) {
  const base = 'macOS';
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
  const base = 'notification';
  const size = 96;

  if (job.theme == 'both' || job.theme == 'light') {
    final light = ImageService.generateNotificationIcon(baseImg, size, Color(job.lightBg), Color(job.lightFg));
    _addFile(archive, '$base/notification_icon_light.png', ImageService.encodePng(light));

    if (job.platforms.contains('android')) {
      kAndroidNotifDrawableSizes.forEach((folder, drawSize) {
        // folder is e.g. 'drawable-xhdpi' — used verbatim as the subfolder name.
        final c = ImageService.generateNotificationIcon(
            baseImg, drawSize, Color(job.lightBg), Color(job.lightFg));
        _addFile(archive, '$base/android/$folder/ic_notification.png', ImageService.encodePng(c));
      });
    }
  }

  if (job.theme == 'both' || job.theme == 'dark') {
    final dark = ImageService.generateNotificationIcon(baseImg, size, Color(job.darkBg), Color(job.darkFg));
    _addFile(archive, '$base/notification_icon_dark.png', ImageService.encodePng(dark));
  }
}

// Per-platform "where do these go" instructions, keyed by platform id.
// Only the sections for job.platforms actually get written to the README,
// so the file always matches exactly what's in the ZIP next to it.
const Map<String, String> _kPlacementDocs = {
  'android': '''### Android — `Android/`
Your Flutter project expects these under `android/app/src/main/res/`, one
folder per screen density — copy each `mipmap-<density>/` folder here
straight into `android/app/src/main/res/`, same name, replacing what's
there:

    Android/mipmap-mdpi/, mipmap-hdpi/, mipmap-xhdpi/, mipmap-xxhdpi/, mipmap-xxxhdpi/
                                        → android/app/src/main/res/mipmap-<density>/
    Android/mipmap-anydpi-v26/         → android/app/src/main/res/mipmap-anydpi-v26/ (adaptive icon XML)''',
  'ios': '''### iOS — `iOS/`
Copy every file in this folder, including `Contents.json`, into
`ios/Runner/Assets.xcassets/AppIcon.appiconset/`, replacing what's there.''',
  'web': '''### Web — `Web/`
Copy `favicon.png` and `favicon.ico` into your Flutter project's `web/`
folder, and the contents of `Web/icons/` into `web/icons/`. Confirm
`web/manifest.json` still points at `Icon-192.png` and `Icon-512.png` by
those names.''',
  'linux': '''### Linux — `Linux/`
Copy these into your project's `linux/` folder:

    my_application.png       (48×48)
    my_application@2x.png    (64×64)
    my_application_128.png   → rename to 128x128/my_application.png
    my_application_256.png   → rename to 256x256/my_application.png''',
  'windows': '''### Windows — `Windows/`
Copy `app_icon.ico` and `app_icon.png` into
`windows/runner/resources/`, replacing the existing files.''',
  'macos': '''### macOS — `macOS/`
Copy every file in this folder, including `Contents.json`, into
`macos/Runner/Assets.xcassets/AppIcon.appiconset/`, replacing what's there.''',
};

String generateReadme(GenerateJob job) {
  final buffer = StringBuffer();
  buffer.writeln('# Flutter App Icons — Generated by FLogo Generator');
  buffer.writeln();
  buffer.writeln(
      'This ZIP contains one capitalised folder per platform you selected,');
  buffer.writeln(
      'with just the generated image/icon files — not a full copy of your');
  buffer.writeln(
      'project\'s folder structure. Follow the section below for each');
  buffer.writeln('platform to see exactly where each file belongs.');
  buffer.writeln();
  buffer.writeln('## What\'s in this ZIP');
  buffer.writeln();
  for (final p in job.platforms) {
    buffer.writeln('- ${_platformLabel(p)}/');
  }
  if (job.genNotif) {
    buffer.writeln('- notification/');
  }
  if (job.platforms.contains('android')) {
    buffer.writeln('- play_store_icon.png (512×512, store listing only)');
  }
  if (job.platforms.contains('ios')) {
    buffer.writeln('- app_store_icon.png (1024×1024, store listing only)');
  }
  buffer.writeln('- README.md (this file)');
  buffer.writeln();
  buffer.writeln('## Where each file goes');
  buffer.writeln();
  for (final p in job.platforms) {
    final doc = _kPlacementDocs[p];
    if (doc != null) {
      buffer.writeln(doc);
      buffer.writeln();
    }
  }
  if (job.platforms.contains('android')) {
    buffer.writeln(
        '`play_store_icon.png` is not part of the app — upload it directly to');
    buffer.writeln('your Play Console store listing.');
    buffer.writeln();
  }
  if (job.platforms.contains('ios')) {
    buffer.writeln(
        '`app_store_icon.png` is not part of the app bundle — upload it directly');
    buffer.writeln('in App Store Connect.');
    buffer.writeln();
  }
  if (job.genNotif) {
    buffer.writeln('### Notification icons — `notification/`');
    buffer.writeln(
        '`notification_icon_light.png` / `notification_icon_dark.png` are');
    buffer.writeln(
        'general-purpose — place them wherever your notification code expects them.');
    if (job.platforms.contains('android')) {
      buffer.writeln(
          '`notification/android/` has density-specific versions that map to');
      buffer.writeln(
          '`android/app/src/main/res/drawable-<density>/ic_notification.png`');
      buffer.writeln('(the folder names already match, e.g. `drawable-xhdpi/`).');
    }
    buffer.writeln();
  }
  buffer.writeln('## Notes');
  buffer.writeln('- All processing was done locally in your browser');
  buffer.writeln('- No images were uploaded to any server');
  buffer.writeln('- Generated: ${DateTime.now().toUtc().toIso8601String()}');
  return buffer.toString();
}

String _platformLabel(String id) {
  switch (id) {
    case 'android':
      return 'Android';
    case 'ios':
      return 'iOS';
    case 'web':
      return 'Web';
    case 'linux':
      return 'Linux';
    case 'windows':
      return 'Windows';
    case 'macos':
      return 'macOS';
    default:
      return id;
  }
}

String _jsonEncodePretty(Map<String, dynamic> data) {
  return const JsonEncoder.withIndent('  ').convert(data);
}
