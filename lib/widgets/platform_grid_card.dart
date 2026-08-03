import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/platform_specs.dart';
import '../models/app_state.dart';
import '../theme/app_colors.dart';
import 'section_card.dart';

class PlatformGridCard extends StatelessWidget {
  /// Number of tiles per row. Callers should pass a divisor of
  /// kPlatforms.length (currently 6, so 1/2/3/6 all divide evenly) so
  /// every row fills edge-to-edge with no ragged trailing gap.
  final int columns;
  const PlatformGridCard({super.key, this.columns = 3});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepLabel(number: 2, title: 'Select Platforms'),
          _buildGrid(context, state),
          const SizedBox(height: 16),
          Row(
            children: [
              _SmallButton(
                label: 'Select All',
                onTap: () => context
                    .read<AppState>()
                    .selectAllPlatforms(kPlatforms.map((e) => e.id).toList()),
              ),
              const SizedBox(width: 8),
              _SmallButton(
                label: 'Clear',
                onTap: () => context.read<AppState>().clearPlatforms(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, AppState state) {
    final cols = columns.clamp(1, kPlatforms.length);
    final rows = <Widget>[];

    for (var i = 0; i < kPlatforms.length; i += cols) {
      final rowItems = kPlatforms.sublist(i, (i + cols).clamp(0, kPlatforms.length));
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 12));
      rows.add(
        // IntrinsicHeight + stretch sizes every tile in the row to match
        // the tallest one's actual content — no hardcoded height to
        // overflow when a subtitle wraps to two lines.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < rowItems.length; j++) ...[
                if (j > 0) const SizedBox(width: 12),
                Expanded(
                  child: _PlatformTile(
                    meta: rowItems[j],
                    selected: state.platforms.contains(rowItems[j].id),
                    onTap: () => context.read<AppState>().togglePlatform(rowItems[j].id),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}

class _PlatformTile extends StatefulWidget {
  final PlatformMeta meta;
  final bool selected;
  final VoidCallback onTap;
  const _PlatformTile({required this.meta, required this.selected, required this.onTap});

  @override
  State<_PlatformTile> createState() => _PlatformTileState();
}

class _PlatformTileState extends State<_PlatformTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, (_hovering && !selected) ? -1 : 0, 0),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent.withOpacity(0.08) : AppColors.surface2,
            borderRadius: BorderRadius.circular(AppColors.radius2),
            border: Border.all(
              color: selected
                  ? AppColors.accent
                  : (_hovering ? AppColors.border2 : AppColors.border),
            ),
          ),
          child: Stack(
            children: [
              if (selected)
                const Positioned(
                  top: -4,
                  right: -2,
                  child: Text('✓',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w700)),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.meta.iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(widget.meta.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.meta.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.meta.desc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: AppColors.text3, height: 1.3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _SmallButton({required this.label, required this.onTap});

  @override
  State<_SmallButton> createState() => _SmallButtonState();
}

class _SmallButtonState extends State<_SmallButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: _hovering ? AppColors.accent : AppColors.border2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(widget.label, style: const TextStyle(fontSize: 12, color: AppColors.text2)),
        ),
      ),
    );
  }
}
