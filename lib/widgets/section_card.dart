import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Port of `.card` — a bordered surface panel with a hover-brighten border,
/// used for every numbered step section.
class SectionCard extends StatefulWidget {
  final Widget child;
  const SectionCard({super.key, required this.child});

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppColors.radius),
          border: Border.all(
            color: _hovering ? AppColors.border2 : AppColors.border,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Port of `.step-label` + `.step-num` + `.step-title` — the numbered
/// heading at the top of every card.
class StepLabel extends StatelessWidget {
  final int number;
  final String title;
  const StepLabel({super.key, required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: AppColors.accentGradient,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
