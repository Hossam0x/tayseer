import 'package:tayseer/my_import.dart';

class AiAssistantBanner extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const AiAssistantBanner({
    super.key,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFf2a6b5),
          border: Border(top: BorderSide(color: Colors.red.withOpacity(0.1))),
        ),
        child: Row(
          children: [
            isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.kprimaryColor,
                    ),
                  )
                : AppImage(AssetsData.kpinIcon),
            const SizedBox(width: 8),

            Expanded(
              child: RichText(
                text: TextSpan(
                  style: Styles.textStyle12.copyWith(color: Colors.black87),
                  children: [
                    TextSpan(text: context.tr('tart_writing_ideas')),
                    TextSpan(
                      text: " ${context.tr('artificial_intelligence')} ",
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.kscandryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: context.tr('help_you_craft_post')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
