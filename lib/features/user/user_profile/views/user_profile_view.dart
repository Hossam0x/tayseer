import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/features/shared/settings/models/setting_item_model.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/marriage_file.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/nav_animation_service.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile/user_profile_image.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile/user_profile_info.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile/user_profile_logout_button.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile/user_profile_setting_item.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile/user_profile_skeleton.dart';
import 'package:tayseer/my_import.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final ScrollController _scrollController = ScrollController();
  int _rating = 0;
  UserProfileCubit? _cubit;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserProfileCubit>(
          create: (context) {
            _cubit = UserProfileCubit(getIt<UserProfileRepository>());
            return _cubit!;
          },
        ),
        BlocProvider.value(value: getIt<ConnectivityCubit>()),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AssetsData.homeBarBackgroundImage,
                fit: BoxFit.cover,
              ),
            ),
            AdvisorBackground(
              child: MultiBlocListener(
                listeners: [
                  BlocListener<UserProfileCubit, UserProfileState>(
                    listenWhen: (previous, current) {
                      if (previous is! SettingsLoaded &&
                          current is SettingsLoaded) {
                        return true;
                      }
                      if (current is SettingsLoaded &&
                          previous is SettingsLoaded) {
                        if (previous.isMarriageSectionDeactivated !=
                            current.isMarriageSectionDeactivated) {
                          return true;
                        }
                        return current.actionTimestamp !=
                            previous.actionTimestamp;
                      }
                      if (current is SettingsLoaded &&
                          current.actionMessage != null) {
                        return true;
                      }
                      return false;
                    },
                    listener: (context, state) {
                      if (state is SettingsLoaded) {
                        final layoutCubit = context.read<LayoutCubit>();
                        if (layoutCubit.state.isMarriageVisible ==
                            state.isMarriageSectionDeactivated) {
                          layoutCubit.updateMarriageVisibility(
                            !state.isMarriageSectionDeactivated,
                          );
                        }
                        if (state.actionMessage == null) return;
                        final isLogout =
                            state.actionMessage == 'logout_success';
                        final isLogoutError =
                            state.actionMessage == 'logout_error';

                        if (isLogout) {
                          _handleLogoutSuccess();
                          return;
                        }
                        if (isLogoutError) {
                          Navigator.pop(context);
                          AppToast.error(context, context.tr("logout_error"));
                          return;
                        }
                        if (state.actionMessage == "update_language_success") {
                          SharedPreferences.getInstance().then((p) {
                            final lang = p.getString(kAppLanguage) ?? 'ar';
                            if (context.mounted) {
                              context.read<LanguageCubit>().setLanguage(
                                lang,
                                context,
                              );
                            }
                          });
                        } else {
                          if (state.isActionSuccess ?? false) {
                            AppToast.success(
                              context,
                              context.tr(state.actionMessage ?? ""),
                            );
                          } else {
                            AppToast.error(
                              context,
                              context.tr(state.actionMessage ?? ""),
                            );
                          }
                        }
                      }
                    },
                  ),
                  BlocListener<LayoutCubit, LayoutState>(
                    listenWhen: (previous, current) =>
                        previous.scrollToTopTrigger !=
                            current.scrollToTopTrigger &&
                        current.currentIndex == 4,
                    listener: (context, state) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                  ),
                  BlocListener<ConnectivityCubit, ConnectivityState>(
                    listenWhen: (prev, curr) =>
                        !prev.isConnected && curr.isConnected,
                    listener: (context, state) =>
                        context.read<UserProfileCubit>().refresh(),
                  ),
                ],
                child: BlocBuilder<UserProfileCubit, UserProfileState>(
                  buildWhen: (previous, current) {
                    if (previous.runtimeType != current.runtimeType) {
                      return true;
                    }
                    if (previous is SettingsLoaded &&
                        current is SettingsLoaded) {
                      return previous.userProfile != current.userProfile ||
                          previous.settings != current.settings ||
                          previous.isMarriageSectionDeactivated !=
                              current.isMarriageSectionDeactivated ||
                          previous.isMarriageProfileComplete !=
                              current.isMarriageProfileComplete;
                    }
                    return true;
                  },
                  builder: (context, state) => _buildBody(context, state),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserProfileState state) {
    return RefreshIndicator(
      onRefresh: () async {
        if (getIt<ConnectivityCubit>().isOffline) return;
        VideoManager.instance.stopAll();
        await context.read<UserProfileCubit>().refresh();
      },
      color: AppColors.kprimaryColor,
      backgroundColor: AppColors.kWhiteColor,
      displacement: 40.h,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16.h,
                left: 20.w,
                right: 20.w,
              ),
              child: Column(
                children: [
                  Gap(18.h),
                  BlocBuilder<UserProfileCubit, UserProfileState>(
                    buildWhen: (previous, current) {
                      if (previous.runtimeType != current.runtimeType) {
                        return true;
                      }
                      if (previous is SettingsLoaded &&
                          current is SettingsLoaded) {
                        return previous.userProfile?.image !=
                                current.userProfile?.image ||
                            previous.userProfile?.name !=
                                current.userProfile?.name ||
                            previous.userProfile?.username !=
                                current.userProfile?.username ||
                            previous.userProfile?.id != current.userProfile?.id;
                      }
                      return true;
                    },
                    builder: (context, state) =>
                        _buildProfileSection(context, state),
                  ),
                ],
              ),
            ),
          ),
          BlocSelector<
            UserProfileCubit,
            UserProfileState,
            List<SettingItemModel>
          >(
            selector: (state) => state is SettingsLoaded ? state.settings : [],
            builder: (context, settings) {
              return SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _buildSettingsList(context, settings, state),
                  ),
                ]),
              );
            },
          ),
          SliverToBoxAdapter(
            child: UserProfileLogoutButton(
              onTap: () => _showLogoutConfirmation(context),
            ),
          ),
          SliverToBoxAdapter(child: Gap(100.h)),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, UserProfileState state) {
    if (state is SettingsInitial || state is SettingsLoading) {
      return const UserProfileSkeleton();
    }
    if (state is SettingsError) {
      return CustomErrorView(
        message: state.message,
        verticalPadding: 40.h,
        onRetry: () async {
          try {
            await context.read<UserProfileCubit>().refresh();
          } catch (_) {}
        },
      );
    }
    if (state is SettingsLoaded) {
      return Column(
        children: [
          UserProfileImage(userProfile: state.userProfile),
          Gap(9.h),
          UserProfileInfo(userProfile: state.userProfile),
          Gap(20.h),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildSettingsList(
    BuildContext context,
    List<SettingItemModel> settings,
    UserProfileState state,
  ) {
    if (settings.isEmpty) {
      return Column(
        children: [
          for (var i = 0; i < 9; i++) ...[
            _buildSettingItemSkeleton(),
            if (i < 8) Divider(color: AppColors.secondary100, height: 1),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (var i = 0; i < settings.length; i++) ...[
          UserProfileSettingItem(
            setting: settings[i],
            state: state,
            onEditProfile: () => _openEditProfile(context),
            onMarriageEdit: _openMarriageEditProfile,
            onMarriageDeactivate: _showDeactivateMarriageDialog,
            onRateApp: _showRateAppDialog,
          ),
          if (i < settings.length)
            Divider(color: AppColors.secondary100, height: 1),
        ],
      ],
    );
  }

  Widget _buildSettingItemSkeleton() {
    return Container(
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
              width: 120.w,
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

  void _openEditProfile(BuildContext context) {
    final cubit = context.read<UserProfileCubit>();
    final currentState = cubit.state;
    if (currentState is! SettingsLoaded || currentState.userProfile == null) {
      return;
    }

    Navigator.pushNamed(
      context,
      AppRouter.kUserProfileEditView,
      arguments: {
        'initialProfile': currentState.userProfile!,
        'onProfileUpdated': (updatedProfile, imageFile) {
          cubit.updateUserProfile(updatedProfile);
        },
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr("logout"),
      supTitle: context.tr("logout_confirmation"),
      imageUrl: AssetsData.kWoriningImage,
      bottonText: context.tr("cancel"),
      cancelText: context.tr("yes"),
      showCancelButton: true,
      onPressed: () {},
      onCancel: () => _performLogout(context),
    );
  }

  void _performLogout(BuildContext context) {
    final cubit = context.read<UserProfileCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: AppColors.primary100)),
    );
    cubit.logout();
  }

  void _handleLogoutSuccess() async {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.kRegisrationView,
      (route) => false,
    );
    AppToast.success(context, context.tr("logout_success"));
  }

  void _showRateAppDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Icon(Icons.close, size: 24.w),
                      ),
                      Text(
                        builderContext.tr("rate_app"),
                        style: Styles.textStyle20Meduim.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                      Gap(24.w),
                    ],
                  ),
                  Gap(25.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setDialogState(() => _rating = index + 1),
                        child: Icon(
                          Icons.star_rounded,
                          color: index < _rating
                              ? AppColors.kprimaryColor
                              : AppColors.secondary100,
                          size: 56.w,
                        ),
                      );
                    }),
                  ),
                  if (_rating > 0) ...[
                    Gap(12.h),
                    Text(
                      '${builderContext.tr("rating")}: $_rating / 5',
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.primary500,
                      ),
                    ),
                  ],
                  Gap(24.h),
                  Text(
                    builderContext.tr("rate_app_message"),
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondary700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(32.h),
                  CustomBotton(
                    title: builderContext.tr("send_rating"),
                    onPressed: () {
                      final ratingToSubmit = _rating;
                      Navigator.pop(dialogContext);
                      _submitAppRating(ratingToSubmit);
                      setDialogState(() => _rating = 0);
                    },
                    width: double.infinity,
                    height: 54.h,
                    useGradient: true,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Marriage methods — DO NOT MODIFY ───────────────────────────────────────

  void _openMarriageEditProfile(BuildContext context, UserProfileState state) {
    if (state is! SettingsLoaded || state.userProfile == null) return;

    final isDataCompleted = state.userProfile!.dataCompleted ?? false;
    if (!isDataCompleted) {
      final layoutCubit = context.read<LayoutCubit>();
      layoutCubit.changeIndex(1);
      return;
    }

    final isProfileComplete = state.isMarriageProfileComplete;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  AssetsData.homeBarBackgroundImage,
                  fit: BoxFit.cover,
                ),
              ),
              MarriagefilePage(
                userProfile: state.userProfile,
                initialTabIndex: isProfileComplete ? 0 : 1,
              ),
            ],
          ),
        ),
      ),
    ).then((result) {
      if (!context.mounted) return;
      if (result != null && result is double) {
        final isComplete = result >= 100;
        context.read<UserProfileCubit>().updateMarriageProgress(isComplete);
      }
    });
  }

  void _showDeactivateMarriageDialog(BuildContext context, bool value) {
    final overlay = Overlay.of(context);
    final flyingIcon = value
        ? AssetsData.consultationIcon
        : AssetsData.ringIcon;

    CustomshowDialogWithImage(
      context,
      title: context.tr(
        value ? "deactivate_marriage_title" : "activate_marriage_title",
      ),
      supTitle: context.tr("activate_marriage_subtitle"),
      imageUrl: AssetsData.marriageRingIcon,
      bottonText: context.tr("yes"),
      cancelText: context.tr("no"),
      showCancelButton: true,
      onPressed: () {
        NavAnimationService.instance.flyIcon(
          fromContext: context,
          iconAsset: flyingIcon,
          overlay: overlay,
          onComplete: () {
            context.read<UserProfileCubit>().updateSwitch(
              'deactivate_the_marriage_section',
              value,
            );
          },
        );
      },
      onCancel: () {},
    );
  }

  // ────────────────────────────────────────────────────────────────────────────

  void _submitAppRating(int rating) {
    if (rating > 0 && _cubit != null) {
      _cubit!.rateApp(rating);
    }
  }
}
