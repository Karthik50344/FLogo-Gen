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

    // Build the ordered list of top-level entries first, so the box-drawing
    // connectors (├── vs └──) can be computed once the full count is known.
    // Each entry is (header line, inner lines already indented one level).
    final entries = <(String, List<String>)>[];

    for (final p in state.platforms) {
      if (p == 'android') {
        final inner = <String>['mipmap-mdpi/, mipmap-hdpi/, mipmap-xhdpi/, mipmap-xxhdpi/, mipmap-xxxhdpi/'];
        inner.add('  each: ic_launcher.png, ic_launcher_round.png'
            '${state.genAdaptive ? ', ic_launcher_foreground.png' : ''}');
        if (state.genAdaptive) {
          inner.add('mipmap-mdpi/ic_launcher_background.png');
          inner.add('mipmap-anydpi-v26/ (adaptive icon XML)');
        }
        entries.add(('Android/', inner));
      }

      if (p == 'ios') {
        entries.add(('iOS/', [
          'Contents.json',
          'Icon-App-20x20@1x.png … @3x.png',
          'Icon-App-60x60@2x.png … @3x.png',
          'ItunesArtwork@2x.png (1024×1024)',
        ]));
      }

      if (p == 'web') {
        entries.add(('Web/', [
          'favicon.png (16×16)',
          'favicon.ico',
          'icons/',
          '  Icon-192.png, Icon-512.png',
          '  Icon-maskable-192.png, Icon-maskable-512.png',
        ]));
      }

      if (p == 'linux') {
        entries.add(('Linux/', [
          'my_application.png (48×48)',
          'my_application@2x.png (64×64)',
          'my_application_128.png',
          'my_application_256.png',
        ]));
      }

      if (p == 'windows') {
        entries.add(('Windows/', [
          'app_icon.ico (16,32,48,256px)',
          'app_icon.png (256×256)',
        ]));
      }

      if (p == 'macos') {
        entries.add(('macOS/', [
          'Contents.json',
          'app_icon_16.png … app_icon_1024.png',
        ]));
      }
    }

    if (state.genNotif) {
      final inner = <String>[];
      if (state.theme == 'both' || state.theme == 'light') {
        inner.add('notification_icon_light.png');
      }
      if (state.theme == 'both' || state.theme == 'dark') {
        inner.add('notification_icon_dark.png');
      }
      if (state.platforms.contains('android')) {
        inner.add('android/');
        inner.add('  mdpi/ … xxxhdpi/ic_notification.png');
      }
      entries.add(('notification/', inner));
    }

    // Root-level files: store-listing icons and README — not nested
    // inside any platform folder, since they aren't part of the app.
    final rootFiles = <String>[
      if (state.platforms.contains('android')) 'play_store_icon.png (512×512, store listing only)',
      if (state.platforms.contains('ios')) 'app_store_icon.png (1024×1024, store listing only)',
      'README.md (where to place each file)',
    ];

    for (var i = 0; i < entries.length; i++) {
      final isLast = i == entries.length - 1 && rootFiles.isEmpty;
      final prefix = isLast ? '└── ' : '├── ';
      final childPrefix = isLast ? '    ' : '│   ';
      final (header, inner) = entries[i];
      lines.add(_TreeLine('  $prefix$header', folder: true));
      for (var j = 0; j < inner.length; j++) {
        final innerLast = j == inner.length - 1;
        final connector = innerLast ? '└── ' : '├── ';
        lines.add(_TreeLine('  $childPrefix$connector${inner[j]}'));
      }
    }

    for (var i = 0; i < rootFiles.length; i++) {
      final isLast = i == rootFiles.length - 1;
      lines.add(_TreeLine('  ${isLast ? '└── ' : '├── '}${rootFiles[i]}'));
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
