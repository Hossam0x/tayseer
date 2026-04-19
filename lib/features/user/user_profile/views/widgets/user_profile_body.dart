import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/features/shared/settings/models/setting_item_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile/user_profile_image.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile/user_profile_info.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile/user_profile_logout_button.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile/user_profile_setting_item.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile/user_profile_skeleton.dart';
import 'package:tayseer/my_import.dart';

class UserProfileBody extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onLogout;
  final void Function(BuildContext) onEditProfile;
  final void Function(BuildContext, UserProfileState) onMarriageEdit;
  final void Function(BuildContext, bool) onMarriageDeactivate;
  final VoidCallback onRateApp;

  const UserProfileBody({
    super.key,
    required this.scrollController,
    required this.onLogout,
    required this.onEditProfile,
    required this.onMarriageEdit,
    required this.onMarriageDeactivate,
    required this.onRateApp,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      buildWhen: (prev, curr) {
        if (prev.runtimeType != curr.runtimeType) return true;
        if (prev is SettingsLoaded && curr is SettingsLoaded) {
          return prev.userProfile != curr.userProfile ||
              prev.settings != curr.settings ||
              prev.isMarriageSectionDeactivated !=
                  curr.isMarriageSectionDeactivated ||
              prev.isMarriageProfileComplete != curr.isMarriageProfileComplete;
        }
        return true;
      },
      builder: (context, state) => RefreshIndicator(
        onRefresh: () async {
          if (getIt<ConnectivityCubit>().isOffline) return;
          AudioService.instance.playRefreshSound();
          VideoManager.instance.stopAll();
          await context.read<UserProfileCubit>().refresh();
        },
        color: AppColors.kprimaryColor,
        backgroundColor: AppColors.kWhiteColor,
        displacement: 40.h,
        child: CustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16.h,
                  left: 20.w,
                  right: 20.w,
                ),
                child: Column(
                  children: [
                    Gap(18.h),
                    _ProfileHeader(state: state),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverToBoxAdapter(
                child: _SettingsList(
                  state: state,
                  onEditProfile: () => onEditProfile(context),
                  onMarriageEdit: onMarriageEdit,
                  onMarriageDeactivate: onMarriageDeactivate,
                  onRateApp: onRateApp,
                ),
              ),
            ),
            SliverToBoxAdapter(child: UserProfileLogoutButton(onTap: onLogout)),
            SliverToBoxAdapter(child: Gap(100.h)),
          ],
        ),
      ),
    );
  }
}

// ── Profile header: image + name + username ──────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserProfileState state;
  const _ProfileHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is SettingsInitial || state is SettingsLoading) {
      return const UserProfileSkeleton();
    }
    if (state is SettingsError) {
      return CustomErrorView(
        message: (state as SettingsError).message,
        verticalPadding: 40.h,
        onRetry: () async {
          try {
            await context.read<UserProfileCubit>().refresh();
          } catch (_) {}
        },
      );
    }
    if (state is SettingsLoaded) {
      final s = state as SettingsLoaded;
      return Column(
        children: [
          UserProfileImage(userProfile: s.userProfile),
          Gap(9.h),
          UserProfileInfo(userProfile: s.userProfile),
          Gap(20.h),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

// ── Settings list with skeleton fallback ─────────────────────────────────────

class _SettingsList extends StatelessWidget {
  final UserProfileState state;
  final VoidCallback onEditProfile;
  final void Function(BuildContext, UserProfileState) onMarriageEdit;
  final void Function(BuildContext, bool) onMarriageDeactivate;
  final VoidCallback onRateApp;

  const _SettingsList({
    required this.state,
    required this.onEditProfile,
    required this.onMarriageEdit,
    required this.onMarriageDeactivate,
    required this.onRateApp,
  });

  @override
  Widget build(BuildContext context) {
    final settings = state is SettingsLoaded
        ? (state as SettingsLoaded).settings
        : <SettingItemModel>[];

    if (settings.isEmpty) return _SkeletonList();

    return Column(
      children: [
        for (var i = 0; i < settings.length; i++) ...[
          UserProfileSettingItem(
            setting: settings[i],
            state: state,
            onEditProfile: onEditProfile,
            onMarriageEdit: onMarriageEdit,
            onMarriageDeactivate: onMarriageDeactivate,
            onRateApp: onRateApp,
          ),
          Divider(color: AppColors.secondary100, height: 1),
        ],
      ],
    );
  }
}

class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 9; i++) ...[
          _SkeletonItem(),
          if (i < 8) Divider(color: AppColors.secondary100, height: 1),
        ],
      ],
    );
  }
}

class _SkeletonItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.secondary200,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Container(
              height: 16.h,
              decoration: BoxDecoration(
                color: AppColors.secondary200,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              color: AppColors.secondary200,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
