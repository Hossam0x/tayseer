import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost/selection_tile.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_edit_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_edit_state.dart';
import 'package:tayseer/features/user/user_profile/views/edit_views/edit_description_view.dart';
import 'package:tayseer/features/user/user_profile/views/edit_views/edit_name_view.dart';
import 'package:tayseer/features/user/user_profile/views/edit_views/edit_profile_image_view.dart';
import 'package:tayseer/features/user/user_profile/views/edit_views/edit_username_view.dart';
import 'package:tayseer/my_import.dart';

class UserProfileEditView extends StatelessWidget {
  final UserProfileModel? initialProfile;

  const UserProfileEditView({super.key, this.initialProfile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserProfileEditCubit(
        getIt<UserProfileRepository>(),
        initialProfile: initialProfile,
      ),
      child: Scaffold(
        body: AdvisorBackground(
          child: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SimpleAppBar(
                      title: 'تعديل البيانات الشخصية',
                      isLargeTitle: true,
                    ),
                    const _UserProfileEditContent(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserProfileEditContent extends StatelessWidget {
  const _UserProfileEditContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileEditCubit, UserProfileEditState>(
      builder: (context, state) {
        final cubit = context.read<UserProfileEditCubit>();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              Gap(32.h),

              if (state.state == CubitStates.loading)
                _buildSkeletonLoading()
              else if (state.state == CubitStates.failure)
                _buildErrorState(context, cubit, state)
              else
                Column(
                  children: [
                    // قسم الصورة الشخصية
                    _buildAvatarImageSection(cubit, state, context),
                    Gap(30.h),

                    // حقل الاسم
                    _buildNameField(cubit, state, context),
                    Gap(16.h),

                    // حقل اسم المستخدم
                    _buildUsernameField(cubit, state, context),
                    Gap(16.h),

                    // حقل النبذة التعريفية
                    _buildDescriptionField(cubit, state, context),
                    Gap(40.h),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLoading() {
    return Column(
      children: [
        Center(
          child: Container(
            height: 150.h,
            width: 155.w,
            decoration: BoxDecoration(
              color: AppColors.secondary100,
              borderRadius: BorderRadius.circular(32.r),
            ),
            child: Center(
              child: Icon(
                Icons.person,
                size: 50.w,
                color: AppColors.secondary300,
              ),
            ),
          ),
        ),
        Gap(30.h),
        _buildSkeletonField(),
        Gap(16.h),
        _buildSkeletonField(),
        Gap(16.h),
        _buildSkeletonField(),
      ],
    );
  }

  Widget _buildSkeletonField() {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.secondary100,
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    UserProfileEditCubit cubit,
    UserProfileEditState state,
  ) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(16.h),
          Text(
            state.errorMessage ?? 'حدث خطأ في تحميل البيانات',
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
          ),
          Gap(24.h),
          CustomBotton(
            width: context.width * 0.6,
            title: 'إعادة المحاولة',
            onPressed: () => cubit.refresh(),
            isLoading: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImageSection(
    UserProfileEditCubit cubit,
    UserProfileEditState state,
    BuildContext context,
  ) {
    final imageUrl = state.imagePreviewUrl;
    final imageFile = state.imageFile;
    final hasImage =
        imageFile != null || (imageUrl != null && imageUrl.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                _navigateToEditProfileImage(context, cubit, state);
              },
              child: Container(
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
                      : (imageUrl != null && imageUrl.isNotEmpty)
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  _navigateToEditProfileImage(context, cubit, state);
                },
                child: AppImage(AssetsData.addCertificateImage, width: 30.w),
              ),
            ),
            if (hasImage)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => cubit.removeImage(),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.kWhiteColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
        ),
        Gap(12.h),
        Text(
          'الصورة الشخصية',
          style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
        ),
        Gap(4.h),
        Text(
          'انقر على أيقونة الكاميرا لتغيير الصورة',
          style: Styles.textStyle12.copyWith(color: AppColors.secondary400),
        ),
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

  Widget _buildNameField(
    UserProfileEditCubit cubit,
    UserProfileEditState state,
    BuildContext context,
  ) {
    return SelectionTile(
      label: 'الاسم',
      value: state.name.isNotEmpty ? state.name : 'أدخل اسمك',
      onTap: () {
        _navigateToEditName(context, cubit, state);
      },
    );
  }

  Widget _buildUsernameField(
    UserProfileEditCubit cubit,
    UserProfileEditState state,
    BuildContext context,
  ) {
    return SelectionTile(
      label: 'اسم المستخدم',
      value: state.username.isNotEmpty ? state.username : 'أدخل اسم المستخدم',
      onTap: () {
        _navigateToEditUsername(context, cubit, state);
      },
    );
  }

  Widget _buildDescriptionField(
    UserProfileEditCubit cubit,
    UserProfileEditState state,
    BuildContext context,
  ) {
    return SelectionTile(
      label: 'نبذة تعريفية',
      value: state.description.isNotEmpty
          ? (state.description.length > 20
                ? '${state.description.substring(0, 20)}...'
                : state.description)
          : 'أضف نبذة تعريفية عن نفسك',
      onTap: () {
        _navigateToEditDescription(context, cubit, state);
      },
    );
  }

  // دالة للانتقال إلى صفحة تعديل الاسم
  void _navigateToEditName(
    BuildContext context,
    UserProfileEditCubit cubit,
    UserProfileEditState state,
  ) {
    final profile = UserProfileModel(
      id: state.profile?.id ?? '',
      name: state.name,
      username: state.username,
      description: state.description,
      image: state.imagePreviewUrl,
      following: state.profile?.following ?? 0,
      isMe: true,
      avaliableForMarry: state.profile?.avaliableForMarry ?? false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNameView(
          initialProfile: profile,
          onProfileUpdated: (updatedProfile) {
            // تحديث الحالة المحلية في الكيوبت
            cubit.updateName(updatedProfile.name);

            // إرجاع البيانات المحدثة إلى الصفحة السابقة
            Navigator.pop(context, updatedProfile);
          },
        ),
      ),
    ).then((updatedProfile) {
      if (updatedProfile != null && updatedProfile is UserProfileModel) {
        // تحديث البيانات إذا تم الحفظ
        cubit.updateName(updatedProfile.name);
      }
    });
  }

  // دالة للانتقال إلى صفحة تعديل اسم المستخدم
  void _navigateToEditUsername(
    BuildContext context,
    UserProfileEditCubit cubit,
    UserProfileEditState state,
  ) {
    final profile = UserProfileModel(
      id: state.profile?.id ?? '',
      name: state.name,
      username: state.username,
      description: state.description,
      image: state.imagePreviewUrl,
      following: state.profile?.following ?? 0,
      isMe: true,
      avaliableForMarry: state.profile?.avaliableForMarry ?? false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUsernameView(
          initialProfile: profile,
          onProfileUpdated: (updatedProfile) {
            cubit.updateUsername(updatedProfile.username);
            Navigator.pop(context, updatedProfile);
          },
        ),
      ),
    ).then((updatedProfile) {
      if (updatedProfile != null && updatedProfile is UserProfileModel) {
        cubit.updateUsername(updatedProfile.username);
      }
    });
  }

  // دالة للانتقال إلى صفحة تعديل النبذة التعريفية
  void _navigateToEditDescription(
    BuildContext context,
    UserProfileEditCubit cubit,
    UserProfileEditState state,
  ) {
    final profile = UserProfileModel(
      id: state.profile?.id ?? '',
      name: state.name,
      username: state.username,
      description: state.description,
      image: state.imagePreviewUrl,
      following: state.profile?.following ?? 0,
      isMe: true,
      avaliableForMarry: state.profile?.avaliableForMarry ?? false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDescriptionView(
          initialProfile: profile,
          onProfileUpdated: (updatedProfile) {
            cubit.updateDescription(updatedProfile.description ?? '');
            Navigator.pop(context, updatedProfile);
          },
        ),
      ),
    ).then((updatedProfile) {
      if (updatedProfile != null && updatedProfile is UserProfileModel) {
        cubit.updateDescription(updatedProfile.description ?? '');
      }
    });
  }

  // دالة للانتقال إلى صفحة تعديل الصورة الشخصية
  void _navigateToEditProfileImage(
    BuildContext context,
    UserProfileEditCubit cubit,
    UserProfileEditState state,
  ) {
    final profile = UserProfileModel(
      id: state.profile?.id ?? '',
      name: state.name,
      username: state.username,
      description: state.description,
      image: state.imagePreviewUrl,
      following: state.profile?.following ?? 0,
      isMe: true,
      avaliableForMarry: state.profile?.avaliableForMarry ?? false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileImageView(
          initialProfile: profile,
          onProfileUpdated: (updatedProfile) {
            // تحديث الصورة في الكيوبت
            cubit.updateImage(updatedProfile.image ?? '');
            Navigator.pop(context, updatedProfile);
          },
        ),
      ),
    ).then((updatedProfile) {
      if (updatedProfile != null && updatedProfile is UserProfileModel) {
        cubit.updateImage(updatedProfile.image ?? '');
      }
    });
  }
}
