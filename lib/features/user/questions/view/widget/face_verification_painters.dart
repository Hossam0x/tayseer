import 'package:flutter/material.dart';
import 'dart:math' as math;

class BadgePainter extends CustomPainter {
  final Color color;

  BadgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const points = 12;

    for (var i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = i.isEven ? radius : radius * 0.85;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

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

class FacePlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;

    final cornerLength = width * 0.25;
    final radius = width * 0.15;

    // الزاوية العلوية اليسرى
    canvas.drawArc(
      Rect.fromLTWH(0, 0, radius * 2, radius * 2),
      math.pi,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawLine(Offset(0, radius), Offset(0, cornerLength), paint);
    canvas.drawLine(Offset(radius, 0), Offset(cornerLength, 0), paint);

    // الزاوية العلوية اليمنى
    canvas.drawArc(
      Rect.fromLTWH(width - radius * 2, 0, radius * 2, radius * 2),
      -math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawLine(Offset(width, radius), Offset(width, cornerLength), paint);
    canvas.drawLine(
      Offset(width - radius, 0),
      Offset(width - cornerLength, 0),
      paint,
    );

    // الزاوية السفلية اليسرى
    canvas.drawArc(
      Rect.fromLTWH(0, height - radius * 2, radius * 2, radius * 2),
      math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(0, height - radius),
      Offset(0, height - cornerLength),
      paint,
    );
    canvas.drawLine(
      Offset(radius, height),
      Offset(cornerLength, height),
      paint,
    );

    // الزاوية السفلية اليمنى
    canvas.drawArc(
      Rect.fromLTWH(
        width - radius * 2,
        height - radius * 2,
        radius * 2,
        radius * 2,
      ),
      0,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(width, height - radius),
      Offset(width, height - cornerLength),
      paint,
    );
    canvas.drawLine(
      Offset(width - radius, height),
      Offset(width - cornerLength, height),
      paint,
    );

    // خطين أفقيين في المنتصف
    final lineY1 = height * 0.4;
    final lineY2 = height * 0.6;
    final lineStartX = width * 0.3;
    final lineEndX = width * 0.7;

    canvas.drawLine(
      Offset(lineStartX, lineY1),
      Offset(lineEndX, lineY1),
      paint,
    );
    canvas.drawLine(
      Offset(lineStartX, lineY2),
      Offset(lineEndX, lineY2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
