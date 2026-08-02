import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../theme/app_colors.dart';
import 'section_card.dart';

class OptionsCard extends StatelessWidget {
  const OptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepLabel(number: 3, title: 'Image Options'),
          _ToggleRow(
            label: 'Remove Background',
            sub: 'Strip white/light background from logo',
            value: state.removeBg,
            onChanged: (v) => context.read<AppState>().setRemoveBg(v),
            showBottomBorder: true,
          ),
          _ToggleRow(
            label: 'Generate Notification Icon',
            sub: 'Common PNG for all platforms (white silhouette)',
            value: state.genNotif,
            onChanged: (v) => context.read<AppState>().setGenNotif(v),
            showBottomBorder: true,
          ),
          _ToggleRow(
            label: 'Adaptive Icon (Android)',
            sub: 'Generate foreground + background layers',
            value: state.genAdaptive,
            onChanged: (v) => context.read<AppState>().setGenAdaptive(v),
            showBottomBorder: false,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: state.removeBg
                ? Container(
                    key: const ValueKey('bg-warning'),
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(AppColors.radius2),
                      border: Border.all(color: AppColors.warning.withOpacity(0.2)),
                    ),
                    child: const Text(
                      'Background removal uses edge detection — works best on logos with '
                      'solid or white backgrounds. Complex photos may have artifacts.',
                      style: TextStyle(fontSize: 12, color: AppColors.warning, height: 1.6),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no-warning')),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showBottomBorder;

  const _ToggleRow({
    required this.label,
    required this.sub,
    required this.value,
    required this.onChanged,
    required this.showBottomBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showBottomBorder
            ? const Border(bottom: BorderSide(color: AppColors.border))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.text3)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              padding: const EdgeInsets.all(2),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: value ? AppColors.accent : AppColors.surface3,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: value ? AppColors.accent : AppColors.border2),
              ),
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
