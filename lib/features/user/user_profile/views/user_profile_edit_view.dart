import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_edit_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_edit_state.dart';
import 'package:tayseer/features/user/user_profile/views/edit_views/edit_description_view.dart';
import 'package:tayseer/features/user/user_profile/views/edit_views/edit_name_view.dart';
import 'package:tayseer/features/user/user_profile/views/edit_views/edit_username_view.dart';
import 'package:tayseer/my_import.dart';

class UserProfileEditView extends StatelessWidget {
  final UserProfileModel? initialProfile;
  final Function(UserProfileModel, File?)? onProfileUpdated;
  final File? localImageFile;

  const UserProfileEditView({
    super.key,
    this.initialProfile,
    this.onProfileUpdated,
    this.localImageFile,
  });

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
                      title: context.tr('edit_profile'),
                      isLargeTitle: true,
                    ),
                    _UserProfileEditContent(
                      onProfileUpdated: onProfileUpdated,
                      localImageFile: localImageFile,
                    ),
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
  final Function(UserProfileModel, File?)? onProfileUpdated;
  final File? localImageFile;

  const _UserProfileEditContent({this.onProfileUpdated, this.localImageFile});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileEditCubit, UserProfileEditState>(
      listener: (context, state) {
        // الاستماع لأي تحديثات في البيانات
        if (state.profile != null && onProfileUpdated != null) {
          onProfileUpdated!(state.profile!, state.imageFile);
        }
      },
      builder: (context, state) {
        final cubit = context.read<UserProfileEditCubit>();

        return Column(
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
                  _buildAvatarImageSection(
                    cubit,
                    state,
                    context,
                    localImageFile,
                  ),
                  Gap(30.h),

                  // حقل الاسم
                  _buildNameField(cubit, state, context),
                  Divider(
                    color: AppColors.secondary,
                    height: 20.h,
                    thickness: 0.2.h,
                  ),

                  // حقل اسم المستخدم
                  _buildUsernameField(cubit, state, context),
                  Divider(
                    color: AppColors.secondary,
                    height: 20.h,
                    thickness: 0.2.h,
                  ),

                  // حقل النبذة التعريفية
                  _buildDescriptionField(cubit, state, context),
                  Gap(40.h),
                ],
              ),
          ],
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
            state.errorMessage ?? context.tr('error_occurred'),
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
          ),
          Gap(24.h),
          CustomBotton(
            width: context.width * 0.6,
            title: context.tr('retry'),
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
    File? localImageFile,
  ) {
    // ⭐ أولوية العرض: imageFile (محلي جديد) > localImageFile (من الـ parent) > imagePreviewUrl (من الباك)
    final imageFile = state.imageFile;
    final imageUrl = state.imagePreviewUrl ?? kCurrentUserData?.image;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => cubit.pickImage(context),
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
                      : localImageFile != null
                      ? Image.file(
                          localImageFile,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : (imageUrl != null && imageUrl.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: AppColors.secondary200,
                          ),
                          errorWidget: (context, error, stackTrace) {
                            debugPrint('❌ خطأ في تحميل الصورة: $imageUrl');
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
                onTap: () => cubit.pickImage(context),
                child: AppImage(AssetsData.addCertificateImage, width: 30.w),
              ),
            ),

            // if (imageUrl != null && imageUrl.isNotEmpty)
            //   Positioned(
            //     top: 10,
            //     right: 10,
            //     child: GestureDetector(
            //       onTap: () => cubit.removeImage(),
            //       child: Container(
            //         padding: EdgeInsets.all(4.w),
            //         decoration: BoxDecoration(
            //           shape: BoxShape.circle,
            //           color: AppColors.kWhiteColor,
            //           boxShadow: [
            //             BoxShadow(
            //               color: Colors.black.withOpacity(0.1),
            //               blurRadius: 4,
            //               offset: const Offset(0, 2),
            //             ),
            //           ],
            //         ),
            //         child: Icon(
            //           Icons.close,
            //           color: AppColors.primary500,
            //           size: 18.w,
            //         ),
            //       ),
            //     ),
            //   ),
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

  Widget _buildNameField(
    UserProfileEditCubit cubit,
    UserProfileEditState state,
    BuildContext context,
  ) {
    return SelectionCard(
      label: context.tr('name'),
      value: state.name.isNotEmpty ? state.name : '',
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
    return SelectionCard(
      label: context.tr('username'),
      value: state.username.isNotEmpty ? state.username : '',
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
    return SelectionCard(
      label: context.tr('description'),
      value: state.description.isNotEmpty
          ? (state.description.length > 20
                ? '${state.description.substring(0, 20)}...'
                : state.description)
          : '',
      onTap: () {
        _navigateToEditDescription(context, cubit, state);
      },
    );
  }

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
      availableForMarry: state.profile?.availableForMarry ?? false,
      age: state.profile?.age ?? 0,
      gender: state.profile?.gender ?? 'male',
      isAnonymous: state.profile?.isAnonymous ?? false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNameView(
          initialProfile: profile,
          onProfileUpdated: (updatedProfile) {
            cubit.updateName(updatedProfile.name);
            if (onProfileUpdated != null) {
              onProfileUpdated!(updatedProfile, state.imageFile);
            }
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

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
      availableForMarry: state.profile?.availableForMarry ?? false,
      age: state.profile?.age ?? 0,
      gender: state.profile?.gender ?? 'male',
      isAnonymous: state.profile?.isAnonymous ?? false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUsernameView(
          initialProfile: profile,
          onProfileUpdated: (updatedProfile) {
            cubit.updateUsername(updatedProfile.username);
            if (onProfileUpdated != null) {
              onProfileUpdated!(updatedProfile, state.imageFile);
            }
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

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
      availableForMarry: state.profile?.availableForMarry ?? false,
      age: state.profile?.age ?? 0,
      gender: state.profile?.gender ?? 'male',
      isAnonymous: state.profile?.isAnonymous ?? false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDescriptionView(
          initialProfile: profile,
          onProfileUpdated: (updatedProfile) {
            cubit.updateDescription(updatedProfile.description ?? '');
            if (onProfileUpdated != null) {
              onProfileUpdated!(updatedProfile, state.imageFile);
            }
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class SelectionCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),

        child: Row(
          children: [
            Text(label, style: Styles.textStyle16Meduim),
            const Spacer(),
            Text(
              value,
              style: Styles.textStyle16.copyWith(color: AppColors.secondary),
            ),
            Gap(10.w),

            Icon(
              Icons.arrow_forward_ios,
              size: 14.w,
              color: AppColors.dropDownArrow,
            ),
          ],
        ),
      ),
    );
  }
}
