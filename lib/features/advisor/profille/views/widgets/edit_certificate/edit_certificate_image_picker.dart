import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/edit_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/edit_certificate_state.dart';
import 'package:tayseer/my_import.dart';

class EditCertificateImagePicker extends StatelessWidget {
  const EditCertificateImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditCertificateCubit, EditCertificateState>(
      buildWhen: (previous, current) =>
          previous.certificateImageFile != current.certificateImageFile ||
          previous.certificateImageUrl != current.certificateImageUrl,
      builder: (context, state) {
        final cubit = context.read<EditCertificateCubit>();
        final hasLocalFile = state.certificateImageFile != null;
        final hasNetworkImage = state.certificateImageUrl != null;
        final hasAnyImage = hasLocalFile || hasNetworkImage;
        const heroTag = 'edit_certificate_image';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(50.h),
            Stack(
              children: [
                GestureDetector(
                  // Tap the image to open fullscreen viewer
                  onTap: hasAnyImage
                      ? () => FullScreenImageView.show(
                          context,
                          imageFile: hasLocalFile
                              ? state.certificateImageFile
                              : null,
                          imageUrl: !hasLocalFile
                              ? state.certificateImageUrl
                              : null,
                          heroTag: heroTag,
                        )
                      : null,
                  child: Container(
                    height: 150.h,
                    width: 155.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(32.r),
                      border: Border.all(
                        color: AppColors.primary100,
                        width: 1.5,
                      ),
                    ),
                    child: hasLocalFile
                        ? Hero(
                            tag: heroTag,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32.r),
                              child: Image.file(
                                state.certificateImageFile!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          )
                        : hasNetworkImage
                        ? Hero(
                            tag: heroTag,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32.r),
                              child: AppImage(
                                state.certificateImageUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.school,
                              size: 40.w,
                              color: Colors.grey.shade500,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 10.r,
                  right: 10.r,
                  child: GestureDetector(
                    onTap: cubit.pickCertificateImage,
                    child: AppImage(
                      AssetsData.addCertificateImage,
                      width: 32.w,
                    ),
                  ),
                ),
                // if (hasAnyImage)
                //   Positioned(
                //     top: 12.r,
                //     right: 12.r,
                //     child: GestureDetector(
                //       onTap: cubit.removeCertificateImage,
                //       child: Container(
                //         padding: const EdgeInsets.all(4),
                //         decoration: BoxDecoration(
                //           shape: BoxShape.circle,
                //           color: AppColors.kWhiteColor,
                //         ),
                //         child: Icon(
                //           Icons.close,
                //           color: AppColors.kRedColor,
                //           size: 20.w,
                //         ),
                //       ),
                //     ),
                //   ),
              ],
            ),
            Gap(8.h),
            Text(
              context.tr('certificate_image_hint'),
              style: Styles.textStyle16.copyWith(color: AppColors.secondary400),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
