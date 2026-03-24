import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_edit/user_profile_edit_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_edit/user_profile_edit_state.dart';
import 'package:tayseer/my_import.dart';

class UserProfileEditAvatar extends StatelessWidget {
  final UserProfileEditCubit cubit;
  final UserProfileEditState state;
  final File? localImageFile;

  const UserProfileEditAvatar({
    super.key,
    required this.cubit,
    required this.state,
    this.localImageFile,
  });

  @override
  Widget build(BuildContext context) {
    final imageFile = state.imageFile;
    final imageUrl = state.imagePreviewUrl ?? kCurrentUserData?.image;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: state.isLoading ? null : () => cubit.pickImage(context),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32.r),
                      child: imageFile != null
                          ? Image.file(
                              imageFile,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : localImageFile != null
                          ? Image.file(
                              localImageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : (imageUrl != null && imageUrl.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) =>
                                  Container(color: AppColors.secondary200),
                              errorWidget: (context, error, stackTrace) =>
                                  _buildDefaultAvatar(),
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                  if (state.isLoading)
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
            if (!state.isLoading)
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => cubit.pickImage(context),
                  child: AppImage(AssetsData.addCertificateImage, width: 30.w),
                ),
              ),
          ],
        ),
        Gap(20.h),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
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
