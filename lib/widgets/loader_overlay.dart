import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../theme/app_colors.dart';

class LoaderOverlay extends StatefulWidget {
  const LoaderOverlay({super.key});

  @override
  State<LoaderOverlay> createState() => _LoaderOverlayState();
}

class _LoaderOverlayState extends State<LoaderOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final visible = state.isGenerating;

    // Always return a Positioned.fill so this Stack child never flips
    // between positioned and non-positioned across frames — toggling
    // that shape is what was causing the "no size" hit-test crash.
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: AppColors.bg.withOpacity(0.85),
              alignment: Alignment.center,
              child: !visible
                  ? const SizedBox.shrink()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RotationTransition(
                          turns: _spinController,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border, width: 3),
                            ),
                            child: CustomPaint(painter: _SpinnerArcPainter()),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          state.loaderText,
                          style: const TextStyle(fontSize: 15, color: AppColors.text2),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < state.loaderSteps.length; i++)
                              _StepRow(
                                label: state.loaderSteps[i],
                                done: i < state.currentStepIndex,
                                active: i == state.currentStepIndex,
                              ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpinnerArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(1.5), -1.4, 1.6, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StepRow extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  const _StepRow({required this.label, required this.done, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.success : (active ? AppColors.accent : AppColors.text3);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 13, fontFamily: 'JetBrainsMono', color: color),
          ),
        ],
      ),
    );
  }
}
