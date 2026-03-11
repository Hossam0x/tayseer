import 'package:flutter/cupertino.dart';
import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/marriage_file.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/nav_animation_service.dart';
import 'package:tayseer/my_import.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  int _rating = 0;
  UserProfileCubit? _cubit;

  // ✅ حذف _userProfileCubit - BlocProvider هيتحكم في الـ lifecycle

  @override
  void dispose() {
    // ✅ حذف _userProfileCubit.close() - BlocProvider بيعمل ده تلقائياً
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
                          // Update language without showing toast
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
                    listener: (context, state) {
                      context.read<UserProfileCubit>().refresh();
                    },
                  ),
                ],
                child: BlocBuilder<UserProfileCubit, UserProfileState>(
                  builder: (context, state) {
                    return _buildBodyContent(context, state);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, UserProfileState state) {
    return RefreshIndicator(
      onRefresh: () async {
        if (getIt<ConnectivityCubit>().isOffline) return;
        VideoManager.instance.stopAll();
        final cubit = context.read<UserProfileCubit>();
        await cubit.refresh();
      },
      color: AppColors.kprimaryColor,
      backgroundColor: AppColors.kWhiteColor,
      displacement: 40.h,
      edgeOffset: 0,
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
                  if (_selectedTabIndex == 0)
                    BlocSelector<
                      UserProfileCubit,
                      UserProfileState,
                      UserProfileModel?
                    >(
                      selector: (state) {
                        if (state is SettingsLoaded) return state.userProfile;
                        return null;
                      },
                      builder: (context, userProfile) {
                        return _buildProfileSection(
                          context,
                          state,
                          userProfile,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          if (_selectedTabIndex == 0)
            BlocSelector<
              UserProfileCubit,
              UserProfileState,
              List<SettingItemModel>
            >(
              selector: (state) {
                if (state is SettingsLoaded) return state.settings;
                return [];
              },
              builder: (context, settings) {
                return _buildGeneralContentSliver(context, state, settings);
              },
            ),
          SliverToBoxAdapter(child: _buildLogoutButton(context)),
          SliverToBoxAdapter(child: Gap(100.h)),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    UserProfileState state,
    UserProfileModel? userProfile,
  ) {
    if (state is SettingsInitial || state is SettingsLoading) {
      return _buildProfileSkeleton();
    }

    if (state is SettingsError) {
      return _buildProfileErrorSection(context, state);
    }

    if (state is SettingsLoaded) {
      return _buildProfileLoadedSection(context, userProfile);
    }

    return const SizedBox();
  }

  Widget _buildProfileSkeleton() {
    return Column(
      children: [
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary200,
          ),
        ),
        Gap(9.h),
        Column(
          children: [
            Container(
              width: 150.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: AppColors.secondary200,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            Gap(4.h),
            Container(
              width: 100.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: AppColors.secondary200,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            Gap(8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  color: AppColors.secondary200,
                ),
                Gap(10.w),
                Container(
                  width: 120.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: AppColors.secondary200,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
            ),
          ],
        ),
        Gap(20.h),
      ],
    );
  }

  Widget _buildProfileErrorSection(BuildContext context, SettingsError state) {
    return CustomErrorView(
      message: state.message,
      verticalPadding: 40.h,
      onRetry: () async {
        final cubit = context.read<UserProfileCubit>();
        try {
          await cubit.refresh();
        } catch (e) {}
      },
    );
  }

  Widget _buildProfileLoadedSection(
    BuildContext context,
    UserProfileModel? userProfile,
  ) {
    return Column(
      children: [
        _buildProfileImage(userProfile),
        Gap(9.h),
        _buildUserInfo(context, userProfile),
        Gap(20.h),
      ],
    );
  }

  Widget _buildProfileImage(UserProfileModel? userProfile) {
    final imageUrl = userProfile?.image ?? kCurrentUserData?.image;

    return SizedBox(
      width: 120.w,
      height: 120.w,
      child: Stack(
        children: [
          GestureDetector(
            onTap: (imageUrl != null && imageUrl.isNotEmpty)
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageView(
                          imageUrl: imageUrl,
                          heroTag: 'user_profile_image',
                          userName:
                              userProfile?.name ?? kCurrentUserData?.name ?? '',
                        ),
                      ),
                    );
                  }
                : null,
            child: Hero(
              tag: 'user_profile_image',
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary100,
                ),
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: AppColors.secondary200,
                          ),
                          errorWidget: (context, url, error) {
                            return Center(
                              child: Icon(
                                Icons.person,
                                size: 48.w,
                                color: AppColors.secondary400,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.person,
                          size: 48.w,
                          color: AppColors.secondary400,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, UserProfileModel? userProfile) {
    if (userProfile == null) {
      return _buildUserInfoSkeleton();
    }

    final displayName = kCurrentUserData?.name ?? userProfile.name;
    final displayUsername = kCurrentUserData?.username ?? userProfile.username;

    return Column(
      children: [
        Text(
          displayName,
          style: Styles.textStyle24Bold.copyWith(color: AppColors.blueText),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),

        if (displayUsername.isNotEmpty) ...[
          Gap(4.h),
          Text(
            displayUsername,
            style: Styles.textStyle16.copyWith(color: AppColors.secondary600),
          ),
        ],

        Gap(8.h),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.kUserPublicProfileView,
              arguments: userProfile.id,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppImage(AssetsData.navigateIcon, width: 12.w),
              Gap(10.w),
              Text(
                context.tr("show_profile"),
                style: Styles.textStyle14.copyWith(
                  color: AppColors.secondary600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoSkeleton() {
    return Column(
      children: [
        Container(
          width: 150.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: AppColors.secondary200,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        Gap(4.h),
        Container(
          width: 100.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: AppColors.secondary200,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        Gap(8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 12.w, height: 12.w, color: AppColors.secondary200),
            Gap(10.w),
            Container(
              width: 120.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: AppColors.secondary200,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ],
        ),
      ],
    );
  }

  SliverList _buildGeneralContentSliver(
    BuildContext context,
    UserProfileState state,
    List<SettingItemModel> settings,
  ) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: _buildSettingsList(context, settings, state),
        ),
      ]),
    );
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
          _buildSettingItem(context, settings[i], state),
          if (i < settings.length)
            Divider(color: AppColors.secondary100, height: 1),
        ],
      ],
    );
  }

  Widget _buildSettingItemSkeleton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.transparent,
      ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: AppColors.secondary200,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
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

  Widget _buildSettingItem(
    BuildContext context,
    SettingItemModel setting,
    UserProfileState state,
  ) {
    final isNotificationsItem = setting.id == 'notifications';
    final isInviteItem = setting.id == 'invite';
    final isRateAppItem = setting.id == 'rate_app';
    final isEditMarriageProfile = setting.id == 'edit_marriage_profile';
    final isDeactiveTheMarriageSection =
        setting.id == 'deactivate_the_marriage_section';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isNotificationsItem) return;
          if (isDeactiveTheMarriageSection) return;

          if (isInviteItem) {
            setting.onTap?.call();
            return;
          }

          if (isRateAppItem) {
            _showRateAppDialog();
            return;
          }

          if (isEditMarriageProfile) {
            _openMarriageEditProfile(context, state);
            return;
          }

          if (setting.id == 'settings') {
            final cubit = context.read<UserProfileCubit>();
            Navigator.pushNamed(
              context,
              AppRouter.kGeneralSettingsView,
              arguments: cubit,
            );
          } else if (setting.routeName.isNotEmpty) {
            if (setting.id == 'language') {
              Navigator.pushNamed(context, setting.routeName).then((result) {
                if (result != null && result is String) {
                  context.read<UserProfileCubit>().updateLanguage(result);
                }
              });
            } else {
              Navigator.pushNamed(context, setting.routeName);
            }
          } else {
            _openEditProfile(context);
          }
        },
        borderRadius: BorderRadius.circular(16.r),
        highlightColor: isNotificationsItem || isDeactiveTheMarriageSection
            ? Colors.transparent
            : null,
        child: Container(
          padding: isNotificationsItem || isDeactiveTheMarriageSection
              ? EdgeInsets.only(top: 12.h, bottom: 12.h, right: 12.w, left: 8.w)
              : EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: isEditMarriageProfile
                ? Border.all(color: AppColors.primary200)
                : null,
            color: isEditMarriageProfile
                ? Color.fromRGBO(235, 122, 145, 0.07)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                padding: EdgeInsets.all(13.w),
                child: AppImage(setting.iconAsset),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        String title = setting.title;
                        return Text(
                          context.tr(title),
                          style: Styles.textStyle16Meduim.copyWith(
                            color:
                                isNotificationsItem ||
                                    isDeactiveTheMarriageSection
                                ? AppColors.secondary800.withOpacity(0.9)
                                : AppColors.secondary800,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              if (setting.hasSwitch)
                if (setting.id == 'notifications' ||
                    setting.id == 'deactivate_the_marriage_section')
                  BlocSelector<UserProfileCubit, UserProfileState, bool>(
                    selector: (state) {
                      if (state is SettingsLoaded) {
                        if (setting.id == 'notifications') {
                          return state.isNotificationEnabled;
                        } else if (setting.id ==
                            'deactivate_the_marriage_section') {
                          return state.isMarriageSectionDeactivated;
                        }
                      }
                      return false;
                    },
                    builder: (context, isEnabled) {
                      return IgnorePointer(
                        ignoring: false,
                        child: Transform.scale(
                          scaleX: -0.9,
                          scaleY: 0.9,
                          child: CupertinoSwitch(
                            value: isEnabled,
                            activeColor: const Color(0xFFF06C88),
                            trackColor: AppColors.dropDownArrow,
                            onChanged: (value) {
                              if (setting.id == 'notifications') {
                                context.read<UserProfileCubit>().updateSwitch(
                                  setting.id,
                                  value,
                                );
                              } else {
                                _showDeactivateMarriageDialog(context, value);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  )
                else
                  IgnorePointer(
                    ignoring: false,
                    child: Transform.scale(
                      scaleX: -0.9,
                      scaleY: 0.9,
                      child: CupertinoSwitch(
                        value: setting.switchValue,
                        activeColor: const Color(0xFFF06C88),
                        trackColor: AppColors.dropDownArrow,
                        onChanged: (value) {
                          final cubit = context.read<UserProfileCubit>();
                          cubit.updateSwitch(setting.id, value);
                        },
                      ),
                    ),
                  )
              else
                _buildTrailingWidget(setting),
            ],
          ),
        ),
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

  Widget _buildTrailingWidget(SettingItemModel setting) {
    if (setting.id == 'invite' ||
        setting.id == 'account_management' ||
        setting.id == 'rate_app') {
      return const SizedBox(width: 0);
    }

    return setting.subtitle != null
        ? Row(
            children: [
              Text(
                context.tr(setting.subtitle!),
                style: Styles.textStyle16.copyWith(color: AppColors.secondary),
              ),
              Gap(4.w),
              Icon(Icons.arrow_forward_ios_rounded, size: 16.w),
            ],
          )
        : Icon(Icons.arrow_forward_ios_rounded, size: 16.w);
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 50.w, right: 50.w, top: 32.h, bottom: 30.h),
      child: InkWell(
        onTap: () => _showLogoutConfirmation(context),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.kRedColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.kRedColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColors.kRedColor,
                size: 22.w,
              ),
              SizedBox(width: 8.w),
              Text(
                context.tr("logout"),
                style: Styles.textStyle16Meduim.copyWith(
                  color: AppColors.kRedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
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
      onCancel: () {
        _performLogout(context);
      },
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
          builder: (builderContext, setState) {
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
                        onTap: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                        child: Icon(
                          index < _rating
                              ? Icons.star_rounded
                              : Icons.star_rounded,
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
                      setState(() {
                        _rating = 0;
                      });
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
      supTitle: context.tr(
        value ? "activate_marriage_subtitle" : "activate_marriage_subtitle",
      ),
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

  // ✅ استخدام _cubit المحفوظ بدلاً من context.read
  void _submitAppRating(int rating) {
    if (rating > 0 && _cubit != null) {
      _cubit!.rateApp(rating);
    }
  }
}
