import 'package:tayseer/core/widgets/custom_error_view.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_edit/user_profile_edit_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_edit/user_profile_edit_state.dart';
import 'package:tayseer/features/user/user_profile/views/edit_views/edit_description_view.dart';
import 'package:tayseer/features/user/user_profile/views/edit_views/edit_name_view.dart';
import 'package:tayseer/features/user/user_profile/views/edit_views/edit_username_view.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile_edit/selection_card.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile_edit/user_profile_edit_avatar.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile_edit/user_profile_edit_skeleton.dart';
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
      child: BlocBuilder<UserProfileEditCubit, UserProfileEditState>(
        buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
        builder: (context, state) {
          return PopScope(
            canPop: !state.isLoading,
            onPopInvokedWithResult: (didPop, result) {},
            child: Scaffold(
              body: AdvisorBackground(
                child: SingleChildScrollView(
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
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
        },
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
              const UserProfileEditSkeleton()
            else if (state.state == CubitStates.failure)
              CustomErrorView(
                message: state.errorMessage,
                onRetry: cubit.refresh,
              )
            else
              Column(
                children: [
                  UserProfileEditAvatar(
                    cubit: cubit,
                    state: state,
                    localImageFile: localImageFile,
                  ),
                  Gap(30.h),
                  SelectionCard(
                    label: context.tr('name'),
                    value: state.name,
                    onTap: () => _navigateToEditName(context, cubit, state),
                  ),
                  Divider(
                    color: AppColors.secondary,
                    height: 20.h,
                    thickness: 0.2.h,
                  ),
                  SelectionCard(
                    label: context.tr('username'),
                    value: state.username,
                    onTap: () => _navigateToEditUsername(context, cubit, state),
                  ),
                  Divider(
                    color: AppColors.secondary,
                    height: 20.h,
                    thickness: 0.2.h,
                  ),
                  SelectionCard(
                    label: context.tr('description'),
                    value: state.description.length > 20
                        ? '${state.description.substring(0, 20)}...'
                        : state.description,
                    onTap: () =>
                        _navigateToEditDescription(context, cubit, state),
                  ),
                  Gap(40.h),
                ],
              ),
          ],
        );
      },
    );
  }

  UserProfileModel _buildProfileFromState(UserProfileEditState state) {
    return UserProfileModel(
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
  }

  void _navigateToEditName(
    BuildContext context,
    UserProfileEditCubit cubit,
    UserProfileEditState state,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNameView(
          initialProfile: _buildProfileFromState(state),
          onProfileUpdated: (updatedProfile) {
            cubit.updateName(updatedProfile.name);
            onProfileUpdated?.call(updatedProfile, state.imageFile);
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUsernameView(
          initialProfile: _buildProfileFromState(state),
          onProfileUpdated: (updatedProfile) {
            cubit.updateUsername(updatedProfile.username);
            onProfileUpdated?.call(updatedProfile, state.imageFile);
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDescriptionView(
          initialProfile: _buildProfileFromState(state),
          onProfileUpdated: (updatedProfile) {
            cubit.updateDescription(updatedProfile.description ?? '');
            onProfileUpdated?.call(updatedProfile, state.imageFile);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
