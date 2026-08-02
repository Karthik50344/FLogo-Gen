import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.flutterBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.flutterBlue.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(size: const Size(20, 20), painter: _FlutterIconPainter()),
              const SizedBox(width: 10),
              const Text(
                'Flutter Asset Generator',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.flutterBlue,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.titleGradient.createShader(bounds),
          child: Text(
            'FLogo\nGenerator',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 500 ? 34 : 50,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 540),
          child: Text(
            'Upload your logo once. Get platform-perfect assets for every Flutter '
            'target — sized, named, and structured exactly as Flutter expects.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.text2, fontSize: 16, height: 1.6),
          ),
        ),
      ],
    );
  }
}

/// Simple redraw of the little Flutter-logo mark used in the badge SVG.
class _FlutterIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48;
    final p1 = Path()
      ..moveTo(14 * s, 38 * s)
      ..lineTo(28 * s, 24 * s)
      ..lineTo(14 * s, 10 * s)
      ..lineTo(26 * s, 10 * s)
      ..lineTo(40 * s, 24 * s)
      ..lineTo(26 * s, 38 * s)
      ..close();
    canvas.drawPath(p1, Paint()..color = const Color(0xFF54C5F8));

    final p2 = Path()
      ..moveTo(14 * s, 38 * s)
      ..lineTo(22 * s, 30 * s)
      ..lineTo(26 * s, 34 * s)
      ..lineTo(18 * s, 38 * s)
      ..close();
    canvas.drawPath(p2, Paint()..color = const Color(0xFF01579B));

    final p3 = Path()
      ..moveTo(22 * s, 30 * s)
      ..lineTo(14 * s, 38 * s)
      ..lineTo(22 * s, 38 * s)
      ..lineTo(30 * s, 30 * s)
      ..close();
    canvas.drawPath(p3, Paint()..color = const Color(0xFF29B6F6).withOpacity(0.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
