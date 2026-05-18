import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_posts_repository.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_public_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/send_greeting_dialog.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_bio.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_header.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_tabs.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_skeletonizer.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/my_import.dart';

class UserPublicProfileView extends StatelessWidget {
  final String userId;

  const UserPublicProfileView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserPublicProfileCubit>(
          create: (_) => UserPublicProfileCubit(
            getIt<UserPublicProfileRepository>(),
            getIt<UserPostsRepository>(),
            getIt<HomeRepository>(),
            userId: userId,
            initialProfile: null,
          ),
        ),
        BlocProvider.value(value: getIt<ConnectivityCubit>()),
      ],
      child: BlocListener<ConnectivityCubit, ConnectivityState>(
        listenWhen: (prev, curr) => !prev.isConnected && curr.isConnected,
        listener: (context, _) =>
            context.read<UserPublicProfileCubit>().refresh(),
        child: Scaffold(
          body: AdvisorBackground(
            child: SafeArea(child: _UserPublicProfileContent()),
          ),
          // floatingActionButton: _buildFloatingActionButton(),
        ),
      ),
    );
  }

  // Widget _buildFloatingActionButton() {
  //   return BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
  //     buildWhen: (prev, curr) =>
  //         prev.state != curr.state ||
  //         prev.profile?.isBlockedByMe != curr.profile?.isBlockedByMe,
  //     builder: (context, state) {
  //       final isBlocked = state.profile?.isBlockedByMe ?? false;
  //       if (state.profile?.isMe == true ||
  //           state.state != CubitStates.success ||
  //           state.profile == null ||
  //           isBlocked ||
  //           isConsultant ||
  //           state.profile?.gender == kCurrentUserData?.gender) {
  //         return const SizedBox.shrink();
  //       }

  //       return Padding(
  //         padding: EdgeInsets.only(bottom: 10.h),
  //         child: CustomClick(
  //           onTap: () {
  //             final cubit = context.read<UserPublicProfileCubit>();
  //             SendGreetingDialog.show(
  //               context,
  //               receiverName: state.profile!.name,
  //               receiverId: state.profile!.id,
  //               cubit: cubit,
  //             );
  //           },
  //           child: FloatingActionButton(
  //             onPressed: null,
  //             backgroundColor: AppColors.kprimaryColor,
  //             shape: const CircleBorder(),
  //             elevation: 4,
  //             child: Container(
  //               width: 56.w,
  //               height: 56.w,
  //               decoration: BoxDecoration(
  //                 shape: BoxShape.circle,
  //                 gradient: LinearGradient(
  //                   begin: Alignment.topCenter,
  //                   end: Alignment.bottomCenter,
  //                   colors: [
  //                     AppColors.kprimaryColor.withOpacity(0.9),
  //                     AppColors.kprimaryColor,
  //                   ],
  //                 ),
  //               ),
  //               child: Padding(
  //                 padding: EdgeInsets.all(10.w),
  //                 child: SvgPicture.asset(
  //                   AssetsData.icSendGreeting,
  //                   width: 26.w,
  //                   height: 26.w,
  //                   color: Colors.white,
  //                   fit: BoxFit.contain,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }


}

class _UserPublicProfileContent extends StatelessWidget {
  const _UserPublicProfileContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
      buildWhen: (prev, curr) => prev.state != curr.state,
      builder: (context, state) {
        if (state.state == CubitStates.loading) {
          return const UserPublicProfileViewSkeletonizer();
        }

        if (state.state == CubitStates.failure && state.profile == null) {
          return _buildFullErrorView(context, state);
        }

        return RefreshIndicator.adaptive(
          onRefresh: () async {
            AudioService.instance.playRefreshSound();
            await context.read<UserPublicProfileCubit>().refresh();
          },
          color: AppColors.kprimaryColor,
          backgroundColor: AppColors.kWhiteColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const UserPublicProfileHeader(),
              const UserPublicProfileBio(),
              SliverToBoxAdapter(child: Gap(20.h)),
              const UserPublicProfileTabs(),
              SliverToBoxAdapter(child: Gap(100.h)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullErrorView(
    BuildContext context,
    UserPublicProfileState state,
  ) {
    return Column(
      children: [
        // زر الرجوع
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColors.secondary600,
                size: 20.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Expanded(
          child: CustomErrorView(
            message: state.profileErrorMessage,
            onRetry: () => context.read<UserPublicProfileCubit>().refresh(),
          ),
        ),
      ],
    );
  }
}
