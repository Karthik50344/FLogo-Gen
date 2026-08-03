import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart' show Color;
import 'package:image/image.dart' as img;

import '../data/platform_specs.dart';
import '../models/app_state.dart';
import 'download_helper.dart';
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

    final steps = <String>[
      'Loading image',
      'Processing image',
      if (state.removeBg) 'Removing background',
      for (final p in state.platforms) 'Generating $p assets',
      if (state.genNotif) 'Creating notification icons',
      'Building ZIP archive',
      'Finalizing download',
    ];

    state.startLoading(steps);
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      var stepIdx = 0;
      await state.setStep(stepIdx++);
      final decoded = ImageService.decode(state.imageBytes!);
      if (decoded == null) {
        state.stopLoading();
        return const GenerateResult(false, 'Error: could not decode image');
      }

      await state.setStep(stepIdx++);
      img.Image baseImg = ImageService.resizeImage(decoded, 1024);

      if (state.removeBg) {
        await state.setStep(stepIdx++);
        baseImg = ImageService.removeBackground(baseImg);
      }

      final archive = Archive();

      for (final platform in state.platforms) {
        await state.setStep(stepIdx++);
        switch (platform) {
          case 'android':
            _addAndroid(archive, baseImg, state.genAdaptive);
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

      if (state.genNotif) {
        await state.setStep(stepIdx++);
        _addNotificationIcons(archive, baseImg, state);
      }

      archive.addFile(ArchiveFile.string('README.md', _generateReadme(state)));

      await state.setStep(stepIdx++); // Building ZIP archive
      final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive) ?? []);

      await state.setStep(stepIdx++); // Finalizing download
      DownloadHelper.downloadBytes(zipBytes, 'flutter_assets.zip');

      await Future.delayed(const Duration(milliseconds: 500));
      state.stopLoading();
      state.clearImage();
      return const GenerateResult(true, 'Assets generated and downloaded!');
    } catch (err) {
      state.stopLoading();
      return GenerateResult(false, 'Error: $err');
    }
  }

  static void _addFile(Archive archive, String path, List<int> bytes) {
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  static void _addAndroid(Archive archive, img.Image baseImg, bool genAdaptive) {
    const base = 'android/app/src/main/res';

    kAndroidMipmapSizes.forEach((folder, sizes) {
      final launcherSize = sizes[0];
      final foregroundSize = sizes[1];

      final launcher = ImageService.resizeImage(baseImg, launcherSize,
          bgColor: const Color(0xFFFFFFFF));
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
      archive.addFile(ArchiveFile.string(
          '$base/mipmap-anydpi-v26/ic_launcher.xml', adaptiveXml));
      archive.addFile(ArchiveFile.string(
          '$base/mipmap-anydpi-v26/ic_launcher_round.xml', adaptiveXml));
    }
  }

  static void _addIos(Archive archive, img.Image baseImg) {
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

  static void _addWeb(Archive archive, img.Image baseImg) {
    final favicon = ImageService.resizeImage(baseImg, 16, bgColor: const Color(0xFFFFFFFF));
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

  static void _addLinux(Archive archive, img.Image baseImg) {
    final app48 = ImageService.resizeImage(baseImg, 48);
    _addFile(archive, 'linux/my_application.png', ImageService.encodePng(app48));

    final app64 = ImageService.resizeImage(baseImg, 64);
    _addFile(archive, 'linux/my_application@2x.png', ImageService.encodePng(app64));

    final app128 = ImageService.resizeImage(baseImg, 128);
    _addFile(archive, 'linux/128x128/my_application.png', ImageService.encodePng(app128));

    final app256 = ImageService.resizeImage(baseImg, 256);
    _addFile(archive, 'linux/256x256/my_application.png', ImageService.encodePng(app256));
  }

  static void _addWindows(Archive archive, img.Image baseImg) {
    final app256 = ImageService.resizeImage(baseImg, 256);
    _addFile(archive, 'windows/runner/resources/app_icon.png', ImageService.encodePng(app256));

    final ico = ImageService.generateIco(baseImg, const [16, 32, 48, 256]);
    _addFile(archive, 'windows/runner/resources/app_icon.ico', ico);
  }

  static void _addMacos(Archive archive, img.Image baseImg) {
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

  static void _addNotificationIcons(Archive archive, img.Image baseImg, AppState state) {
    const size = 96;

    if (state.theme == 'both' || state.theme == 'light') {
      final light = ImageService.generateNotificationIcon(
          baseImg, size, state.lightBg, state.lightFg);
      _addFile(archive, 'notification/notification_icon_light.png', ImageService.encodePng(light));

      if (state.platforms.contains('android')) {
        kAndroidNotifDrawableSizes.forEach((folder, drawSize) {
          final c = ImageService.generateNotificationIcon(
              baseImg, drawSize, state.lightBg, state.lightFg);
          _addFile(archive, 'android/app/src/main/res/$folder/ic_notification.png',
              ImageService.encodePng(c));
        });
      }
    }

    if (state.theme == 'both' || state.theme == 'dark') {
      final dark = ImageService.generateNotificationIcon(
          baseImg, size, state.darkBg, state.darkFg);
      _addFile(archive, 'notification/notification_icon_dark.png', ImageService.encodePng(dark));
    }
  }

  static String _generateReadme(AppState state) {
    final platforms = state.platforms.join(', ');
    final buffer = StringBuffer();
    buffer.writeln('# Flutter Assets — Generated by FLogo Generator');
    buffer.writeln();
    buffer.writeln('## Platforms: $platforms');
    buffer.writeln();
    buffer.writeln('## How to use');
    buffer.writeln();
    buffer.writeln('### Android');
    buffer.writeln("Copy the contents of `android/` into your Flutter project's `android/` directory.");
    buffer.writeln('The `play_store_icon.png` goes in your Play Store listing.');
    if (state.genAdaptive) {
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
    if (state.genNotif && state.platforms.contains('android')) {
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

  static String _jsonEncodePretty(Map<String, dynamic> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}

