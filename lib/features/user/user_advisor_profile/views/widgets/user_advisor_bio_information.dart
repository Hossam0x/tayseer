import 'package:tayseer/features/shared/profile/widgets/bio_sections.dart';
import 'package:tayseer/features/user/user_advisor_profile/data/models/user_advisor_profile_model.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserAdvisorBioInformation extends StatelessWidget {
  const UserAdvisorBioInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UserAdvisorProfileCubit, UserAdvisorProfileState>(
          listenWhen: (previous, current) =>
              previous.followActionState != current.followActionState &&
              current.followActionState != CubitStates.initial,
          listener: _handleFollowState,
        ),
        BlocListener<UserAdvisorProfileCubit, UserAdvisorProfileState>(
          listenWhen: (previous, current) =>
              previous.blockActionState != current.blockActionState &&
              current.blockActionState != CubitStates.initial,
          listener: _handleBlockState,
        ),
        BlocListener<UserAdvisorProfileCubit, UserAdvisorProfileState>(
          listenWhen: (previous, current) =>
              previous.chatActionState != current.chatActionState &&
              current.chatActionState == CubitStates.failure,
          listener: (context, state) {
            if (state.chatErrorMessage != null) {
              showSafeSnackBar(
                context: context,
                text: state.chatErrorMessage!,
                isError: true,
              );
            }
          },
        ),
      ],
      child: BlocBuilder<UserAdvisorProfileCubit, UserAdvisorProfileState>(
        buildWhen: (previous, current) {
          if (previous.profileState != current.profileState) return true;
          if (previous.profile == null && current.profile != null) return true;
          if (previous.profile != null && current.profile == null) return true;
          if (previous.profile != null && current.profile != null) {
            return previous.profile!.name != current.profile!.name ||
                previous.profile!.username != current.profile!.username ||
                previous.profile!.aboutYou != current.profile!.aboutYou ||
                previous.profile!.professionalSpecialization !=
                    current.profile!.professionalSpecialization ||
                previous.profile!.yearsOfExperience !=
                    current.profile!.yearsOfExperience ||
                previous.profile!.location != current.profile!.location ||
                previous.profile!.isMe != current.profile!.isMe;
          }
          return false;
        },
        builder: (context, state) {
          switch (state.profileState) {
            case CubitStates.loading:
              return SliverToBoxAdapter(child: _buildSkeleton(context));
            case CubitStates.failure:
              return SliverToBoxAdapter(
                child: _buildError(context, state.profileErrorMessage),
              );
            case CubitStates.success:
              if (state.profile != null) {
                return SliverToBoxAdapter(
                  child: _buildContent(context, state.profile!),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            default:
              return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
        },
      ),
    );
  }

  void _handleFollowState(BuildContext context, UserAdvisorProfileState state) {
    final message = state.followMessage;
    switch (state.followActionState) {
      case CubitStates.success:
        state.isFollowAdded == true
            ? AppToast.success(context, message ?? context.tr('follow_success'))
            : AppToast.info(context, message ?? context.tr('unfollow_success'));
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? context.tr('follow_error'));
        break;
      default:
        break;
    }
  }

  void _handleBlockState(BuildContext context, UserAdvisorProfileState state) {
    final message = state.blockMessage;
    final isBlocked = state.profile?.room?.isBlocked ?? false;
    switch (state.blockActionState) {
      case CubitStates.success:
        AppToast.success(
          context,
          isBlocked
              ? (message ?? context.tr('user_blocked_successfully'))
              : (message ?? context.tr('unblocked_successfully')),
        );
        break;
      case CubitStates.failure:
        AppToast.error(
          context,
          message ??
              (isBlocked
                  ? context.tr('failed_to_block')
                  : context.tr('failed_to_unblock')),
        );
        break;
      default:
        break;
    }
  }

  Widget _buildSkeleton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: _buildContent(
        context,
        const UserAdvisorProfileModel(
          id: '1',
          name: 'اسم المستخدم',
          image: '',
          username: '@username',
          aboutYou: 'وصف قصير عن المستخدم',
          followers: 0,
          following: 0,
          isVerified: false,
          location: '',
          isMe: false,
          isFollowing: false,
          videoLink: null,
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String? errorMessage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.kRedColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.kRedColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: AppColors.kRedColor, size: 32.w),
          Gap(10.h),
          Text(
            errorMessage ?? context.tr('error_loading_data'),
            style: Styles.textStyle14.copyWith(color: AppColors.kRedColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserAdvisorProfileModel profile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SharedBioNameSection(
            name: profile.name,
            verificationType: profile.verificationType,
          ),
          if (profile.username.isNotEmpty) ...[
            Text(
              profile.username,
              style: Styles.textStyle14.copyWith(color: AppColors.hintText),
            ),
            Gap(8.h),
          ],
          SharedBioProfessionalInfo(
            displaySpecialization: profile.displaySpecialization,
            displayYearsExperience: profile.displayYearsExperience,
          ),
          SharedBioLocationSection(location: profile.location),
          SharedBioAboutSection(aboutYou: profile.aboutYou),
          if (!profile.isMe) _buildFollowSection(context, profile),
        ],
      ),
    );
  }

  Widget _buildFollowSection(
    BuildContext context,
    UserAdvisorProfileModel profile,
  ) {
    return BlocConsumer<UserAdvisorProfileCubit, UserAdvisorProfileState>(
      listenWhen: (previous, current) =>
          previous.profile?.isFollowing != current.profile?.isFollowing ||
          previous.profile?.room != current.profile?.room ||
          previous.isChatLoading != current.isChatLoading ||
          previous.followActionState != current.followActionState ||
          previous.blockActionState != current.blockActionState,
      listener: (context, state) {},
      buildWhen: (previous, current) =>
          previous.profile?.isFollowing != current.profile?.isFollowing ||
          previous.profile?.room != current.profile?.room ||
          previous.isChatLoading != current.isChatLoading ||
          previous.followActionState != current.followActionState ||
          previous.blockActionState != current.blockActionState,
      builder: (context, state) {
        final isBlocked = state.profile?.room?.isBlocked ?? false;
        final isFollowing = state.profile?.isFollowing ?? false;
        final isLoadingFollow = state.followActionState == CubitStates.loading;
        final isLoadingBlock = state.blockActionState == CubitStates.loading;
        final isChatLoading = state.isChatLoading;
        final room = state.profile?.room;
        final bool isSomeActionLoading =
            isLoadingFollow || isChatLoading || isLoadingBlock;
        final bool isFollowSmall = isFollowing && !isBlocked;
        final bool showBookSession = !isBlocked && isFollowing && isUser;
        final bool showChat = !isBlocked && isFollowing;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            children: [
              if (isFollowSmall)
                _buildFollowButton(
                  context: context,
                  isBlocked: isBlocked,
                  isFollowing: isFollowing,
                  isLoadingBlock: isLoadingBlock,
                  isLoadingFollow: isLoadingFollow,
                  isSomeActionLoading: isSomeActionLoading,
                  profile: profile,
                  isSmall: true,
                )
              else
                Expanded(
                  child: _buildFollowButton(
                    context: context,
                    isBlocked: isBlocked,
                    isFollowing: isFollowing,
                    isLoadingBlock: isLoadingBlock,
                    isLoadingFollow: isLoadingFollow,
                    isSomeActionLoading: isSomeActionLoading,
                    profile: profile,
                    isSmall: false,
                  ),
                ),
              if (showBookSession) ...[
                Gap(13.w),
                Expanded(
                  child: _buildBookSessionButton(
                    context,
                    isSomeActionLoading,
                    profile,
                  ),
                ),
              ],
              if (showChat) ...[
                Gap(13.w),
                if (showBookSession)
                  _buildChatButton(
                    context,
                    isSomeActionLoading,
                    profile,
                    room,
                    isChatLoading,
                    isSmall: true,
                  )
                else
                  Expanded(
                    child: _buildChatButton(
                      context,
                      isSomeActionLoading,
                      profile,
                      room,
                      isChatLoading,
                      isSmall: false,
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFollowButton({
    required BuildContext context,
    required bool isBlocked,
    required bool isFollowing,
    required bool isLoadingBlock,
    required bool isLoadingFollow,
    required bool isSomeActionLoading,
    required UserAdvisorProfileModel profile,
    required bool isSmall,
  }) {
    return CustomClick(
      onTap: isSomeActionLoading
          ? null
          : () {
              if (isBlocked) {
                context.read<UserAdvisorProfileCubit>().unblockUser(
                  advisorId: profile.id,
                );
                return;
              }
              context.read<UserAdvisorProfileCubit>().toggleFollow();
            },
      child: Container(
        height: 54.h,
        width: isSmall ? 54.w : double.infinity,
        decoration: BoxDecoration(
          color: (isFollowing || isBlocked)
              ? (isFollowing && !isBlocked
                    ? AppColors.primary100
                    : AppColors.kWhiteColor)
              : AppColors.kprimaryColor,
          gradient: (isFollowing || isBlocked)
              ? null
              : AppColors.defaultGradient,
          borderRadius: BorderRadius.circular(10.r),
          border: (isFollowing || isBlocked)
              ? Border.all(
                  color: isFollowing && !isBlocked
                      ? AppColors.primary500
                      : AppColors.kprimaryColor,
                )
              : null,
        ),
        child: Center(
          child: (isBlocked ? isLoadingBlock : isLoadingFollow)
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: (isFollowing || isBlocked)
                        ? AppColors.kprimaryColor
                        : Colors.white,
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: isBlocked
                      ? Text(
                          context.tr('unblock'),
                          key: const ValueKey('unblock'),
                          style: Styles.textStyle14SemiBold.copyWith(
                            color: AppColors.kprimaryColor,
                          ),
                        )
                      : isFollowing
                      ? Icon(
                          Icons.how_to_reg,
                          key: const ValueKey('followed'),
                          color: AppColors.primary500,
                          size: 24.w,
                        ).animate().scale(
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        )
                      : Text(
                          context.tr('follow'),
                          key: const ValueKey('follow'),
                          style: Styles.textStyle14SemiBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
        ),
      ),
    );
  }

  Widget _buildBookSessionButton(
    BuildContext context,
    bool isSomeActionLoading,
    UserAdvisorProfileModel profile,
  ) {
    return CustomClick(
      onTap: isSomeActionLoading
          ? null
          : () => Navigator.pushNamed(
              context,
              AppRouter.advisorchatprofile,
              arguments: {'advisorid': profile.id},
            ),
      child: Container(
        height: 54.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.primary100,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.kprimaryColor),
        ),
        child: Center(
          child: Text(
            context.tr('book_session'),
            style: Styles.textStyle14SemiBold.copyWith(
              color: AppColors.kprimaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatButton(
    BuildContext context,
    bool isSomeActionLoading,
    UserAdvisorProfileModel profile,
    dynamic room,
    bool isChatLoading, {
    required bool isSmall,
  }) {
    return CustomClick(
      onTap: isSomeActionLoading
          ? null
          : () => context.read<UserAdvisorProfileCubit>().startChat(),
      child: Container(
        height: 54.h,
        width: isSmall ? 54.w : double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary100,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.primary500),
        ),
        child: Center(
          child: isChatLoading
              ? SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary500,
                  ),
                )
              : AppImage(AssetsData.chatIconSVG, width: 22.w),
        ),
      ),
    );
  }
}
