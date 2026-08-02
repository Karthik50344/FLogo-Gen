import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../theme/app_colors.dart';
import 'color_picker_dialog.dart';
import 'section_card.dart';

class ThemeCard extends StatelessWidget {
  final bool twoColumnFields;
  const ThemeCard({super.key, this.twoColumnFields = true});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepLabel(number: 4, title: 'Notification Icon Theme'),
          Row(
            children: [
              Expanded(
                child: _ThemeOption(
                  label: 'Both',
                  sub: 'Light + Dark',
                  selected: state.theme == 'both',
                  swatch: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF8F9FA), Color(0xFF1A1A2E)],
                    stops: [0.5, 0.5],
                  ),
                  onTap: () => context.read<AppState>().setTheme('both'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ThemeOption(
                  label: 'Light only',
                  sub: 'Single file',
                  selected: state.theme == 'light',
                  swatch: const LinearGradient(
                    colors: [Color(0xFFF8F9FA), Color(0xFFDEE2E6)],
                  ),
                  onTap: () => context.read<AppState>().setTheme('light'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ThemeOption(
                  label: 'Dark only',
                  sub: 'Single file',
                  selected: state.theme == 'dark',
                  swatch: const LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                  onTap: () => context.read<AppState>().setTheme('dark'),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Builder(builder: (context) {
              final fields = [
                _ColorField(
                  label: 'Light theme background',
                  color: state.lightBg,
                  onChanged: (c) => context.read<AppState>().setColor('lightBg', c),
                ),
                _ColorField(
                  label: 'Light theme icon color',
                  color: state.lightFg,
                  onChanged: (c) => context.read<AppState>().setColor('lightFg', c),
                ),
                _ColorField(
                  label: 'Dark theme background',
                  color: state.darkBg,
                  onChanged: (c) => context.read<AppState>().setColor('darkBg', c),
                ),
                _ColorField(
                  label: 'Dark theme icon color',
                  color: state.darkFg,
                  onChanged: (c) => context.read<AppState>().setColor('darkFg', c),
                ),
              ];

              if (!twoColumnFields) {
                return Column(
                  children: [
                    for (var i = 0; i < fields.length; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: i == fields.length - 1 ? 0 : 14),
                        child: fields[i],
                      ),
                  ],
                );
              }

              // Two even columns, computed once by the caller (home_screen's
              // outer LayoutBuilder) rather than guessed here — keeps this
              // widget free of LayoutBuilder/Wrap so it stays safe under an
              // IntrinsicHeight ancestor, and always divides the 4 fields
              // evenly with no ragged edge.
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: fields[0]),
                      const SizedBox(width: 14),
                      Expanded(child: fields[1]),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: fields[2]),
                      const SizedBox(width: 14),
                      Expanded(child: fields[3]),
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final String sub;
  final bool selected;
  final Gradient swatch;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.sub,
    required this.selected,
    required this.swatch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withOpacity(0.07) : AppColors.surface2,
          borderRadius: BorderRadius.circular(AppColors.radius2),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(gradient: swatch, borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                  Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.text3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorField extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  const _ColorField({required this.label, required this.color, required this.onChanged});

  String _hex(Color c) => '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text2)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface3,
            borderRadius: BorderRadius.circular(AppColors.radius2),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await ColorPickerDialog.show(context, color);
                  if (picked != null) onChanged(picked);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _hex(color),
                  style: const TextStyle(fontSize: 13, color: AppColors.text, fontFamily: 'JetBrainsMono'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
