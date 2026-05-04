import 'dart:ui';
import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/core/widgets/screenshot_protected_image.dart';
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
  Future<void> _syncNotificationAfterInteraction(context) async {
    await context.read<MarriageCubit>().fetchAndSyncNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ heroTag فريد لكل صورة
    final String heroTag = 'additional_image_$imageUrl';

    return GestureDetector(
      onTap: shouldBlur
          ? null // ✅ لو الصورة مبلورة متفتحش
          : () => FullScreenImageView.show(
              context,
              imageUrl: imageUrl,
              heroTag: heroTag,
            ),
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // ✅ الصورة مع دعم الـ blur والحماية من الـ screenshot
              if (shouldBlur)
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: SizedBox(
                    width: double.infinity,
                    height: context.height * 0.4,
                    child: ScreenshotProtectedImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      shouldBlur: false,
                      isAnimating: true, // ✅ يمنع Hero الداخلي
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: context.height * 0.4,
                  child: ScreenshotProtectedImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    isAnimating: true, // ✅ يمنع Hero الداخلي
                  ),
                ),

              // ✅ طبقة تعتيم فوق الـ blur
              if (shouldBlur)
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.2)),
                ),

              // ✅ زر النجمة
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
                          final regardsLeft =
                              context.read<MarriageCubit>().state.regardsLeft;
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
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
