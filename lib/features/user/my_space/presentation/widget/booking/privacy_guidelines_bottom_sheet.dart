import 'package:tayseer/my_import.dart';

class PrivacyGuidelinesBottomSheet extends StatelessWidget {
  const PrivacyGuidelinesBottomSheet({super.key});

  /// ★ دالة لفتح الـ Bottom Sheet
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PrivacyGuidelinesBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ─── 1. الهاندل ───
              _buildHandle(),

              // ─── 2. المحتوى القابل للتمرير ───
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    Gap(context.responsiveHeight(16)),

                    // ─── العنوان ───
                    Text(
                      context.tr('privacy_guidelines_title'),
                      textAlign: TextAlign.center,
                      style: Styles.textStyle20Bold.copyWith(
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),

                    Gap(context.responsiveHeight(32)),

                    // ─── العناصر ───
                    _GuidelineItem(
                      title: context.tr('full_confidentiality'),
                      description: context.tr('full_confidentiality_desc'),
                    ),

                    _GuidelineItem(
                      title: context.tr('trusted_procedure'),
                      description: context.tr('trusted_procedure_desc'),
                    ),

                    _GuidelineItem(
                      title: context.tr('your_privacy_matters'),
                      description: context.tr('your_privacy_matters_desc'),
                    ),

                    _GuidelineItem(
                      title: context.tr('interact_freely'),
                      description: context.tr('interact_freely_desc'),
                    ),

                    _GuidelineItem(
                      title: context.tr('complete_comfort'),
                      description: context.tr('complete_comfort_desc'),
                      showDivider: false,
                    ),

                    Gap(context.responsiveHeight(24)),
                  ],
                ),
              ),

              // ─── 3. زر "احجز الآن" ───
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: CustomBotton(
                  width: double.infinity,
                  title: context.tr('book_now'),
                  useGradient: true,
                  onPressed: () {
                    Navigator.pop(context);
                    // ★ ممكن تضيف navigation هنا
                  },
                ),
              ),

              // Safe area للأجهزة اللي فيها نوتش
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
// في نفس الملف أو ملف منفصل

class _GuidelineItem extends StatelessWidget {
  final String title;
  final String description;
  final bool showDivider;

  const _GuidelineItem({
    required this.title,
    required this.description,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── الأيقونة + العنوان ───
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 18),
              const SizedBox(width: 8),

              Text(
                title,
                style: Styles.textStyle16.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ─── الوصف ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              textAlign: TextAlign.right,
              style: Styles.textStyle14.copyWith(
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
          ),

          if (showDivider) ...[
            const SizedBox(height: 20),
            Divider(
              color: Colors.grey.shade100,
              thickness: 1,
              indent: 40,
              endIndent: 40,
            ),
          ],
        ],
      ),
    );
  }
}
