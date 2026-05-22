import 'package:tayseer/core/widgets/screenshot_protected_image.dart';
import 'package:tayseer/features/user/marriage/view/widget/marriage_full_screen_image_view.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/regards_purchase_sheet.dart';
import 'package:tayseer/my_import.dart';

class AdditionalImageSection extends StatelessWidget {
  final String imageUrl;
  final String? personId;
  final bool? isHastar;
  final bool shouldBlur;

  const AdditionalImageSection({
    super.key,
    required this.imageUrl,
    this.personId,
    this.isHastar,
    this.shouldBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    // heroTag فريد لكل صورة
    final String heroTag = 'additional_image_$imageUrl';

    return Hero(
      tag: heroTag,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // الصورة مع دعم الـ blur والحماية من الـ screenshot
            // shouldBlur بيتمرر لـ ScreenshotProtectedImage مباشرة
            // على iOS: لما shouldBlur=true بيستخدم Flutter image + ImageFiltered
            //          لما shouldBlur=false بيستخدم SecureImageWrapper (UiKitView)
            SizedBox(
              width: double.infinity,
              height: context.height * 0.4,
              child: ScreenshotProtectedImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                shouldBlur: shouldBlur,
                isAnimating: true,
              ),
            ),

            // طبقة تعتيم فوق الـ blur
            if (shouldBlur)
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),

            // طبقة شفافة فوق الـ UiKitView تمسك الـ tap
            // على iOS الـ UiKitView بيبلع الـ touch events حتى لو gestureRecognizers فاضية
            // الحل: Positioned.fill شفاف فوقه يمسك الـ tap ويفتح الـ full screen
            if (!shouldBlur)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => MarriageFullScreenImageView.show(
                    context,
                    imageUrl: imageUrl,
                    heroTag: heroTag,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),

            // زر النجمة
            if (isHastar == true)
              Positioned(
                bottom: 15.h,
                left: 15.w,
                child: SizedBox(
                  width: 44.r,
                  height: 44.r,
                  child: CircleAvatar(
                    backgroundColor: HexColor('cccab3'),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.star,
                        color: AppColors.kWhiteColor,
                        size: 22.r,
                      ),
                      onPressed: () {
                        if (personId == null) return;
                        final regardsLeft = context
                            .read<MarriageCubit>()
                            .state
                            .regardsLeft;
                        if (regardsLeft == 0) {
                          showRegardsPurchaseSheet(context);
                          return;
                        }
                        showRegardInputSheet(
                          context,
                          personId: personId!,
                          personName: '',
                          onSend: (text) {
                            context.read<MarriageCubit>().sendRegardText(
                              personId: personId!,
                              text: text,
                              countView: true,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
