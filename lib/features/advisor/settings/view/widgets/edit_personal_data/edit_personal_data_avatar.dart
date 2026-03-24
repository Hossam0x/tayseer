import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_state.dart';
import 'package:tayseer/my_import.dart';

class EditPersonalDataAvatar extends StatelessWidget {
  final EditPersonalDataCubit cubit;
  final EditPersonalDataState state;
  final VoidCallback onPickImage;

  const EditPersonalDataAvatar({
    super.key,
    required this.cubit,
    required this.state,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = state.imagePreviewUrl;
    final imageFile = state.imageFile;
    final isImageDeleted = state.currentData.image == "";

    return Stack(
      children: [
        GestureDetector(
          onTap:
              !state.isSaving &&
                  !isImageDeleted &&
                  (imageFile != null ||
                      (imageUrl != null && imageUrl.isNotEmpty))
              ? () => FullScreenImageView.show(
                  context,
                  imageUrl: imageUrl,
                  imageFile: imageFile,
                  heroTag: 'advisor_edit_profile_avatar',
                  userName: state.profile?.name,
                )
              : null,
          child: Hero(
            tag: 'advisor_edit_profile_avatar',
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 150.h,
                  width: 155.w,
                  decoration: BoxDecoration(
                    color: AppColors.hintText,
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                  child: isImageDeleted
                      ? _defaultAvatar()
                      : imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(32.r),
                          child: Image.file(
                            imageFile,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _defaultAvatar(),
                          ),
                        )
                      : imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(32.r),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorWidget: (_, __, ___) => _defaultAvatar(),
                          ),
                        )
                      : _defaultAvatar(),
                ),
                if (state.isSaving)
                  Container(
                    height: 150.h,
                    width: 155.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(32.r),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 56.w,
                        height: 56.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: state.uploadProgress > 0
                                  ? state.uploadProgress
                                  : null,
                              strokeWidth: 4,
                              color: AppColors.kprimaryColor,
                              backgroundColor: Colors.white24,
                            ),
                            Text(
                              '${(state.uploadProgress * 100).toInt()}%',
                              style: Styles.textStyle12.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!state.isSaving)
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: onPickImage,
              child: AppImage(AssetsData.addCertificateImage, width: 30.w),
            ),
          ),
        if (!state.isSaving &&
            !isImageDeleted &&
            (imageFile != null || (imageUrl != null && imageUrl.isNotEmpty)))
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: cubit.removeImage,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kWhiteColor,
                ),
                child: Icon(
                  Icons.close,
                  color: AppColors.primary500,
                  size: 18.w,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32.r),
      child: Container(
        color: AppColors.primary100,
        child: Center(
          child: Icon(Icons.person, size: 60.w, color: AppColors.primary300),
        ),
      ),
    );
  }
}
