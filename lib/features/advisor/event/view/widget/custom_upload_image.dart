
import 'dart:ui';

import 'package:tayseer/my_import.dart';

class CustomUploadContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const CustomUploadContainer({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DottedBorderPainter(color: const Color(0xFFEFA6A8)),
        child: Container(
          width: double.infinity,
          height: context.height * 0.3,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFEFA6A8), size: 30),
              const SizedBox(height: 12),

              Text(
                title,
                style: Styles.textStyle14.copyWith(
                  color: const Color(0xFFEFA6A8),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Styles.textStyle12.copyWith(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SelectedImageItem extends StatelessWidget {
  const SelectedImageItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 100,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF70C1B3)),
            color: const Color(0xFFEFFFFC),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),

            child: const Icon(Icons.image, color: Color(0xFF70C1B3), size: 40),
          ),
        ),

        Positioned(
          top: -8,
          left: -8,
          child: GestureDetector(
            onTap: () {
              // Delete logic
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red, // لون الزر
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  const _DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color.withOpacity(0.5)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    final Path path =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            const Radius.circular(12),
          ),
        );

    // تحويل المسار المتصل إلى منقط
    final Path dashPath = Path();
    double dashWidth = 6.0;
    double dashSpace = 4.0;
    double distance = 0.0;

    for (final PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
