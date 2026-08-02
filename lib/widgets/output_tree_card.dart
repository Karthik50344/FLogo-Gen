import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../theme/app_colors.dart';
import 'section_card.dart';

class OutputTreeCard extends StatelessWidget {
  const OutputTreeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lines = _buildTreeLines(state);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepLabel(number: 5, title: 'Output Structure Preview'),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 260, minHeight: 80),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(AppColors.radius2),
              border: Border.all(color: AppColors.border),
            ),
            child: lines.isEmpty
                ? const Text(
                    'Select platforms above to see the output structure',
                    style: TextStyle(
                        color: AppColors.text3, fontStyle: FontStyle.italic, fontSize: 13),
                  )
                : SingleChildScrollView(
                    child: SelectableText.rich(
                      TextSpan(children: _renderSpans(lines)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<_TreeLine> _buildTreeLines(AppState state) {
    if (state.platforms.isEmpty) return [];

    final lines = <_TreeLine>[];
    lines.add(_TreeLine('flutter_assets.zip', folder: true));

    if (state.genNotif) {
      lines.add(_TreeLine('  notification/', folder: true));
      if (state.theme == 'both' || state.theme == 'light') {
        lines.add(_TreeLine('    notification_icon_light.png'));
      }
      if (state.theme == 'both' || state.theme == 'dark') {
        lines.add(_TreeLine('    notification_icon_dark.png'));
      }
    }

    final platforms = state.platforms.toList();
    for (var pi = 0; pi < platforms.length; pi++) {
      final p = platforms[pi];
      final isLast = pi == platforms.length - 1;
      final prefix = isLast ? '└── ' : '├── ';
      final childPrefix = isLast ? '    ' : '│   ';

      if (p == 'android') {
        lines.add(_TreeLine('  $prefix' 'android/app/src/main/res/', folder: true));
        for (final folder in [
          'mipmap-mdpi',
          'mipmap-hdpi',
          'mipmap-xhdpi',
          'mipmap-xxhdpi',
          'mipmap-xxxhdpi'
        ]) {
          lines.add(_TreeLine('  $childPrefix├── $folder/', folder: true));
          lines.add(_TreeLine('  $childPrefix│   ├── ic_launcher.png'));
          lines.add(_TreeLine('  $childPrefix│   ├── ic_launcher_round.png'));
          if (state.genAdaptive) {
            lines.add(_TreeLine('  $childPrefix│   └── ic_launcher_foreground.png'));
          }
        }
        lines.add(_TreeLine('  $childPrefix└── play_store_icon.png (512×512)'));
      }

      if (p == 'ios') {
        lines.add(_TreeLine(
            '  $prefix' 'ios/Runner/Assets.xcassets/AppIcon.appiconset/',
            folder: true));
        lines.add(_TreeLine('  $childPrefix├── Icon-App-20x20@1x.png … @3x.png'));
        lines.add(_TreeLine('  $childPrefix├── Icon-App-60x60@2x.png … @3x.png'));
        lines.add(_TreeLine('  $childPrefix└── ItunesArtwork@2x.png (1024×1024)'));
      }

      if (p == 'web') {
        lines.add(_TreeLine('  $prefix' 'web/', folder: true));
        lines.add(_TreeLine('  $childPrefix├── favicon.png (16×16)'));
        lines.add(_TreeLine('  $childPrefix└── icons/', folder: true));
        lines.add(_TreeLine('  $childPrefix    ├── Icon-192.png'));
        lines.add(_TreeLine('  $childPrefix    ├── Icon-512.png'));
        lines.add(_TreeLine('  $childPrefix    ├── Icon-maskable-192.png'));
        lines.add(_TreeLine('  $childPrefix    └── Icon-maskable-512.png'));
      }

      if (p == 'linux') {
        lines.add(_TreeLine('  $prefix' 'linux/', folder: true));
        lines.add(_TreeLine('  $childPrefix├── my_application.png (48×48)'));
        lines.add(_TreeLine('  $childPrefix├── my_application@2x.png (64×64)'));
        lines.add(_TreeLine('  $childPrefix├── 128x128/my_application.png', folder: true));
        lines.add(_TreeLine('  $childPrefix└── 256x256/my_application.png', folder: true));
      }

      if (p == 'windows') {
        lines.add(_TreeLine('  $prefix' 'windows/runner/resources/', folder: true));
        lines.add(_TreeLine('  $childPrefix├── app_icon.ico (16,32,48,256px)'));
        lines.add(_TreeLine('  $childPrefix└── app_icon.png (256×256)'));
      }

      if (p == 'macos') {
        lines.add(_TreeLine(
            '  $prefix' 'macos/Runner/Assets.xcassets/AppIcon.appiconset/',
            folder: true));
        lines.add(_TreeLine('  $childPrefix├── app_icon_16.png … app_icon_1024.png'));
      }
    }

    return lines;
  }

  List<InlineSpan> _renderSpans(List<_TreeLine> lines) {
    final spans = <InlineSpan>[];
    for (var i = 0; i < lines.length; i++) {
      spans.add(TextSpan(
        text: lines[i].text,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12,
          height: 1.8,
          color: lines[i].folder ? AppColors.flutterBlue : AppColors.text2,
        ),
      ));
      if (i != lines.length - 1) spans.add(const TextSpan(text: '\n'));
    }
    return spans;
  }
}

class _TreeLine {
  final String text;
  final bool folder;
  _TreeLine(this.text, {this.folder = false});
}
