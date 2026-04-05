// lib/features/user/questions/view/widget/face_verification_painters.dart

import 'dart:math';
import 'package:flutter/material.dart';

class FacePlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final cornerLen = w * 0.25;

    // Top-left corner
    canvas.drawLine(Offset(0, cornerLen), Offset.zero, paint);
    canvas.drawLine(Offset.zero, Offset(cornerLen, 0), paint);

    // Top-right corner
    canvas.drawLine(Offset(w - cornerLen, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cornerLen), paint);

    // Bottom-left corner
    canvas.drawLine(Offset(0, h - cornerLen), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(cornerLen, h), paint);

    // Bottom-right corner
    canvas.drawLine(Offset(w, h - cornerLen), Offset(w, h), paint);
    canvas.drawLine(Offset(w - cornerLen, h), Offset(w, h), paint);

    // Center line
    final linePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(w * 0.2, h * 0.5),
      Offset(w * 0.8, h * 0.5),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BadgePainter extends CustomPainter {
  final Color color;

  BadgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final path = Path();

    const points = 12;
    const innerRatio = 0.85;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final r = i.isEven ? radius : radius * innerRatio;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
