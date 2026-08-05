import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';

class DotGridOverlay extends StatelessWidget {
  const DotGridOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotGridPainter());
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppThemeConstants.primaryColor.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    const double spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
