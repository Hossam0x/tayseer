// ════════════════════════════════════════════════════════════════
// ✅ ImageSlotCard - يدعم local files و network images
// ════════════════════════════════════════════════════════════════
import 'dart:ui' as ui;

import 'package:tayseer/my_import.dart';

class ImageSlotCard extends StatelessWidget {
  final String? imageUrl;
  final File? localFile; // ✅ للصور المحلية pending
  final bool isMain;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const ImageSlotCard({
    super.key,
    this.imageUrl,
    this.localFile,
    this.isMain = false,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null || localFile != null;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!hasImage)
            CustomPaint(
              painter: DashedRectPainter(
                color: AppColors.kbinkColor,
                strokeWidth: 1.5,
                gap: 5.0,
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(Icons.add, size: 32, color: AppColors.kbinkColor),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                image: DecorationImage(
                  // ✅ FileImage للصور المحلية، NetworkImage للسيرفر
                  image: localFile != null
                      ? FileImage(localFile!) as ImageProvider
                      : NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // ✅ أيقونة صغيرة للصور الـ pending
          if (localFile != null)
            Positioned(
              bottom: 2,
              left: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.save_outlined,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),

          if (isMain)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: HexColor('b11b39'),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  context.tr('main_Image'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (hasImage && onRemove != null)
            Positioned(
              top: 4,
              left: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// DashedRectPainter
// ════════════════════════════════════════════════════════════════
class DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double gap;

  DashedRectPainter({
    this.strokeWidth = 1.0,
    this.color = Colors.grey,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    Path dashPath = Path();
    double dashWidth = 6.0;
    double dashSpace = gap;
    double distance = 0.0;

    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    canvas.drawPath(dashPath, dashedPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
