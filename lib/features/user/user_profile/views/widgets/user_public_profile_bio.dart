import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserPublicProfileBio extends StatelessWidget {
  const UserPublicProfileBio({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UserPublicProfileCubit, UserPublicProfileState>(
          listenWhen: (previous, current) =>
              previous.blockActionState != current.blockActionState &&
              current.blockActionState != CubitStates.initial,
          listener: _handleBlockState,
        ),
      ],
      child: BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
        buildWhen: (previous, current) =>
            previous.profileState != current.profileState ||
            previous.profile != current.profile,
        builder: (context, state) {
          switch (state.profileState) {
            case CubitStates.loading:
              return SliverToBoxAdapter(child: _buildSkeletonBio(context));
            case CubitStates.failure:
              return _buildErrorBio(context, state.profileErrorMessage);
            case CubitStates.success:
              if (state.profile != null) {
                return SliverToBoxAdapter(
                  child: _buildBioContent(context, state.profile!),
                );
              }
              return _buildEmptyBio();
            default:
              return _buildEmptyBio();
          }
        },
      ),
    );
  }

  void _handleBlockState(BuildContext context, UserPublicProfileState state) {
    final message = state.blockMessage;
    final isBlocked = state.profile?.isBlockedByMe ?? false;

    switch (state.blockActionState) {
      case CubitStates.success:
        showSafeSnackBar(
          context: context,
          text: isBlocked
              ? context.tr('user_blocked_successfully')
              : context.tr('unblocked_successfully'),
          isSuccess: true,
        );
        break;
      case CubitStates.failure:
        showSafeSnackBar(
          context: context,
          text:
              message ??
              (isBlocked
                  ? context.tr('failed_to_unblock')
                  : context.tr('failed_to_unblock')), // or generic error
          isError: true,
        );
        break;
      default:
        break;
    }
  }

  Widget _buildSkeletonBio(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: _buildBioContent(
        context,
        const UserProfileModel(
          id: '',
          name: 'اسم المستخدم',
          username: '@username',
          description: 'وصف المستخدم',
          image: '',
          following: 0,
          isMe: false,
          age: 0,
          gender: 'ذكر',
          isAnonymous: false,
          availableForMarry: false,
        ),
      ),
    );
  }

  Widget _buildErrorBio(BuildContext context, String? errorMessage) {
    return SliverToBoxAdapter(
      child: Container(
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
      ),
    );
  }

  Widget _buildBioContent(BuildContext context, UserProfileModel profile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الاسم
          Row(
            children: [
              Text(
                profile.name,
                style: Styles.textStyle20SemiBold.copyWith(
                  color: AppColors.blueText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              // if (profile.isVerified ?? false) ...[
              //   Gap(8.w),
              //   Icon(Icons.verified, color: Colors.blue, size: 20.w),
              // ],
            ],
          ),
          Gap(4.h),

          // اسم المستخدم
          if (profile.username.isNotEmpty) ...[
            Text(
              profile.username,
              style: Styles.textStyle14.copyWith(color: AppColors.hintText),
            ),
            Gap(8.h),
          ],

          // حالة الجاهزية للزواج
          if (!profile.isMe &&
              !isConsultant &&
              profile.gender != kCurrentUserData?.gender) ...[
            profile.availableForMarry
                ? Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: CustomBotton(
                      width: 200.w,
                      height: 40.h,
                      backGroundcolor: AppColors.primary400,
                      title: context.tr('view_marriage_profile'),
                      onPressed: () {
                        if (isGuest) {
                          CustomshowDialogWithImage(
                            context,
                            title: context.tr('joinUs'),
                            supTitle: context.tr("guest_login_first"),
                            icon: Icons.lock_person_outlined,
                            iconColor: AppColors.kprimaryColor,
                            bottonText: context.tr("login"),
                            showCancelButton: true,
                            cancelText: context.tr('skip'),
                            onPressed: () {
                              CachNetwork.removeData(key: ktoken);
                              context.pushNamedAndRemoveUntil(
                                AppRouter.kRegisrationView,
                                predicate: (_) => false,
                              );
                            },
                            onCancel: () {},
                          );
                          return;
                        }

                        context.pushNamed(
                          AppRouter.kMarriageView,
                          arguments: {'personId': profile.id},
                        );
                      },
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary400,
                      borderRadius: BorderRadius.circular(34.r),
                    ),
                    child: Text(
                      context.tr('unavailable'),
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.secondary950,
                      ),
                    ),
                  ),
            Gap(12.h),
          ],

          // الوصف
          if (profile.description != null && profile.description!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
              child: Text(
                profile.description!,
                style: Styles.textStyle14.copyWith(
                  color: AppColors.infoText,
                  height: 1.5,
                ),
                textAlign: TextAlign.start,
              ),
            ),

          // زر إلغاء الحظر (إذا كان محظوراً)
          if (!profile.isMe) _buildActionSection(context, profile),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, UserProfileModel profile) {
    return BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
      buildWhen: (previous, current) =>
          previous.profile?.isBlockedByMe != current.profile?.isBlockedByMe ||
          previous.blockActionState != current.blockActionState,
      builder: (context, state) {
        final isBlocked = state.profile?.isBlockedByMe ?? false;
        final isLoadingBlock = state.blockActionState == CubitStates.loading;

        if (!isBlocked) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: CustomBotton(
            height: 54.h,
            width: double.infinity,
            title: context.tr('unblock'),
            onPressed: isLoadingBlock
                ? null
                : () {
                    context.read<UserPublicProfileCubit>().unblockUser(
                      userId: profile.id,
                    );
                  },
            backGroundcolor: AppColors.kWhiteColor,
            titleColor: AppColors.kprimaryColor,
            radius: 10.r,
            useGradient: false,
            isLoading: isLoadingBlock,
            elevation: 0,
          ),
        );
      },
    );
  }

  // Widget _buildContactButton(BuildContext context) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
  //     child: CustomBotton(
  //       height: 54.h,
  //       width: double.infinity,
  //       title: 'تواصل معي',
  //       onPressed: () {
  //         // TODO: افتح محادثة مع المستخدم
  //         // Navigator.pushNamed(context, AppRouter.ic);
  //       },
  //       backGroundcolor: AppColors.kprimaryColor,
  //       titleColor: AppColors.kWhiteColor,
  //       radius: 10.r,
  //       useGradient: true,
  //       elevation: 0,
  //     ),
  //   );
  // }

  SliverToBoxAdapter _buildEmptyBio() {
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
