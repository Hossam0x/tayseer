import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/add_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/add_certificate_state.dart';
import 'package:tayseer/my_import.dart';

class AddCertificateImagePicker extends StatelessWidget {
  const AddCertificateImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddCertificateCubit, AddCertificateState>(
      buildWhen: (previous, current) =>
          previous.certificateImageFile != current.certificateImageFile,
      builder: (context, state) {
        final cubit = context.read<AddCertificateCubit>();
        final hasImage = state.certificateImageFile != null;
        const heroTag = 'add_certificate_image';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(50.h),
            Stack(
              children: [
                GestureDetector(
                  // When image exists → open fullscreen; otherwise → pick image
                  onTap: hasImage
                      ? () => FullScreenImageView.show(
                          context,
                          imageFile: state.certificateImageFile,
                          heroTag: heroTag,
                        )
                      : cubit.pickCertificateImage,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: hasImage ? 0 : 45.r,
                    ),
                    height: 190.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.kWhiteColor,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.primary100),
                    ),
                    child: hasImage
                        ? Hero(
                            tag: heroTag,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: Image.file(
                                state.certificateImageFile!,
                                fit: BoxFit.fitWidth,
                                width: double.infinity,
                              ),
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppImage(
                                  AssetsData.uplaodCertificate,
                                  width: 35.w,
                                ),
                                Gap(8.h),
                                Text(
                                  context.tr('upload_image_or_pdf'),
                                  style: Styles.textStyle16Meduim.copyWith(
                                    color: AppColors.mentionBlue,
                                  ),
                                ),
                                Gap(8.h),
                                Text(
                                  textAlign: TextAlign.center,
                                  context.tr('certificate_image_requirements'),
                                  style: Styles.textStyle12.copyWith(
                                    color: AppColors.secondary400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                // Re-pick button shown only when an image is already selected
                if (hasImage)
                  Positioned(
                    bottom: 10.r,
                    right: 10.r,
                    child: GestureDetector(
                      onTap: cubit.pickCertificateImage,
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.kWhiteColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6.r,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 20.w,
                          color: AppColors.kprimaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
