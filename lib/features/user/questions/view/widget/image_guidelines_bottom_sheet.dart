// lib/core/widgets/image_guidelines_bottom_sheet.dart

import 'package:tayseer/my_import.dart';

class ImageGuidelinesBottomSheet extends StatelessWidget {
  const ImageGuidelinesBottomSheet({super.key});

  /// ✅ دالة لعرض الـ Bottom Sheet
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onNext,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => ImageGuidelinesBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: context.height * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ العنوان الرئيسي
            Text(
              context.tr('use_high_quality_photos'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ✅ الصور الصحيحة (إطار أخضر)
            _buildCorrectImagesSection(context),
            const SizedBox(height: 24),

            // ✅ عنوان الأخطاء
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                context.tr('avoid_these_mistakes'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ الصور الخاطئة (إطار أحمر)
            _buildWrongImagesSection(context),
            const SizedBox(height: 24),

            // ✅ زر التالي
            SizedBox(
              width: double.infinity,
              child: CustomBotton(
                useGradient: true,
                title: context.tr('next'),
                onPressed: () {
                  context.pop();
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectImagesSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildImageCard(
            context: context,
            imagePath: AssetsData.kCorrectImage1,
            label: 'show_yourself_only',
            isCorrect: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildImageCard(
            context: context,
            imagePath: AssetsData.kCorrectImage1,
            label: 'clear_face',
            isCorrect: true,
          ),
        ),
      ],
    );
  }

  Widget _buildWrongImagesSection(BuildContext context) {
    return Column(
      children: [
        // الصف الأول
        Row(
          children: [
            Expanded(
              child: _buildImageCard(
                context: context,
                imagePath: AssetsData.kWrongImageNotPerson,
                label: 'not_a_person',
                isCorrect: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildImageCard(
                context: context,
                imagePath: AssetsData.kWrongImageAI,
                label: 'ai_generated_photo',
                isCorrect: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // الصف الثاني
        Row(
          children: [
            Expanded(
              child: _buildImageCard(
                context: context,
                imagePath: AssetsData.kWrongImageCovered,
                label: 'face_covered',
                isCorrect: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildImageCard(
                context: context,
                imagePath: AssetsData.kWrongImageFar,
                label: 'too_far',
                isCorrect: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard({
    required BuildContext context,
    required String imagePath,
    required String label,
    required bool isCorrect,
  }) {
    final borderColor = isCorrect
        ? const Color(0xFF4CAF50)
        : const Color(0xFFE53935);
    final bgColor = isCorrect
        ? const Color(0xFF4CAF50).withOpacity(0.1)
        : const Color(0xFFE53935).withOpacity(0.1);

    return Column(
      children: [
        // ✅ الصورة مع الإطار
        Container(
          height: context.height * 0.25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    size: 40,
                    color: borderColor,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ✅ Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            context.tr(label),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: borderColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
