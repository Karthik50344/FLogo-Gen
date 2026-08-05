import 'package:flutter/material.dart';

/// Standard transparency checkerboard, drawn behind a (possibly
/// semi-transparent) color swatch so the user can actually see how
/// transparent the selected color is.
class CheckerboardSwatch extends StatelessWidget {
  final Color color;
  final double size;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const CheckerboardSwatch({
    super.key,
    required this.color,
    this.size = 28,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width ?? size,
        height: height ?? size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _CheckerPainter()),
            ColoredBox(color: color),
          ],
        ),
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 6.0;
    final light = Paint()..color = const Color(0xFFCCCCCC);
    final dark = Paint()..color = const Color(0xFF999999);
    canvas.drawRect(Offset.zero & size, light);
    for (double y = 0; y < size.height; y += cell) {
      for (double x = 0; x < size.width; x += cell) {
        final isDark = ((x / cell).floor() + (y / cell).floor()) % 2 == 0;
        if (isDark) {
          canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), dark);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
