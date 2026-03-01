import 'package:flutter/cupertino.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';

import 'package:tayseer/core/cubits/toggle_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_state.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/rating_cubit.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/my_import.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late SettingsCubit _settingsCubit;

  @override
  void initState() {
    super.initState();
    _settingsCubit = SettingsCubit(getIt<UserProfileRepository>());
  }

  @override
  void dispose() {
    _settingsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _settingsCubit,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AdvisorBackground(
          child: BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (previous, current) {
              if (current is SettingsLoaded && previous is SettingsLoaded) {
                return current.actionTimestamp != previous.actionTimestamp;
              }
              // Handle first action when state becomes loaded
              if (current is SettingsLoaded &&
                  (current.actionSuccess != null ||
                      current.actionError != null)) {
                return true;
              }
              return false;
            },
            listener: (context, state) {
              if (state is SettingsLoaded) {
                if (state.actionSuccess != null) {
                  showSafeSnackBar(
                    context: context,
                    text: state.isActionKey
                        ? context.tr(state.actionSuccess!)
                        : state.actionSuccess!,
                    isSuccess: true,
                    duration: const Duration(milliseconds: 1500),
                  );
                  // Special handling for language update side effect
                  if (state.actionSuccess == "update_language_success") {
                    SharedPreferences.getInstance().then((p) {
                      final lang = p.getString('app_language') ?? 'ar';
                      context.read<LanguageCubit>().setLanguage(lang);
                    });
                  }
                  context.read<SettingsCubit>().clearMessages();
                } else if (state.actionError != null) {
                  showSafeSnackBar(
                    context: context,
                    text: state.isActionKey
                        ? context.tr(state.actionError!)
                        : state.actionError!,
                    isError: true,
                  );
                  context.read<SettingsCubit>().clearMessages();
                }
              }
            },
            child: _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 105.h,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AssetsData.homeBarBackgroundImage),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        Column(
          children: [
            // Static Header
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Gap(16.h),
                    SimpleAppBar(title: context.tr("settings_title")),
                  ],
                ),
              ),
            ),

            // Dynamic Content
            Expanded(
              child: BlocBuilder<SettingsCubit, SettingsState>(
                buildWhen: (previous, current) {
                  if (previous is SettingsLoaded && current is SettingsLoaded) {
                    return previous.settings != current.settings;
                  }
                  return true;
                },
                builder: (context, state) {
                  if (state is SettingsError) {
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Gap(20.h),
                            Text(
                              state.message,
                              style: Styles.textStyle16.copyWith(
                                color: AppColors.kWhiteColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Gap(20.h),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<SettingsCubit>().refresh(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                              ),
                              child: Text(
                                context.tr("retry"),
                                style: Styles.textStyle16Meduim.copyWith(
                                  color: AppColors.kWhiteColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is SettingsLoaded) {
                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          sliver: _buildSettingsSliverList(
                            context,
                            state.settings,
                          ),
                        ),

                        SliverToBoxAdapter(child: _buildLogoutButton(context)),
                        SliverToBoxAdapter(child: Gap(30.h)),
                      ],
                    );
                  }

                  // Loading State
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.kprimaryColor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSliverList(
    BuildContext context,
    List<SettingItemModel> settings,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index.isOdd) {
          return Divider(color: AppColors.secondary100, height: 1);
        }
        final itemIndex = index ~/ 2;
        final setting = settings[itemIndex];
        return _buildSettingItem(context, setting);
      }, childCount: settings.length * 2 - 1),
    );
  }

  Widget _buildSettingItem(BuildContext context, SettingItemModel setting) {
    final isNotificationsItem = setting.id == 'notifications';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isNotificationsItem
              ? null
              : () => _handleSettingTap(context, setting),
          borderRadius: BorderRadius.circular(16.r),
          highlightColor: isNotificationsItem ? Colors.transparent : null,
          child: Container(
            padding: isNotificationsItem
                ? EdgeInsets.only(
                    top: 12.h,
                    bottom: 12.h,
                    right: 12.w,
                    left: 8.w,
                  )
                : EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: Colors.transparent,
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
                      Text(
                        context.tr(setting.title),
                        style: Styles.textStyle16Meduim.copyWith(
                          color: isNotificationsItem
                              ? AppColors.secondary800.withOpacity(0.9)
                              : AppColors.secondary800,
                        ),
                      ),
                    ],
                  ),
                ),

                if (setting.hasSwitch)
                  BlocBuilder<SettingsCubit, SettingsState>(
                    buildWhen: (previous, current) {
                      if (previous is SettingsLoaded &&
                          current is SettingsLoaded) {
                        return previous.isNotificationEnabled !=
                            current.isNotificationEnabled;
                      }
                      return false;
                    },
                    builder: (context, state) {
                      final isEnabled = state is SettingsLoaded
                          ? state.isNotificationEnabled
                          : false;
                      return IgnorePointer(
                        ignoring: false,
                        child: Transform.scale(
                          scaleX: -1,
                          scaleY: 1,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final screenWidth = MediaQuery.of(
                                context,
                              ).size.width;
                              final scaleFactor = screenWidth > 600 ? 1.5 : 1.0;

                              return Transform.scale(
                                scale: scaleFactor,
                                child: CupertinoSwitch(
                                  value: isEnabled,
                                  activeColor: const Color(0xFFF06C88),
                                  trackColor: AppColors.dropDownArrow,
                                  onChanged: (value) {
                                    context.read<SettingsCubit>().updateSwitch(
                                      setting.id,
                                      value,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  )
                else
                  _buildTrailingWidget(context, setting),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingWidget(BuildContext context, SettingItemModel setting) {
    if (setting.id == 'invite' || setting.id == 'account_management') {
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
              Icon(Icons.arrow_forward_ios_rounded, size: 18.w),
            ],
          )
        : Icon(Icons.arrow_forward_ios_rounded, size: 18.w);
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 50.w, right: 50.w, top: 30.h),
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
      imageUrl: AssetsData.pauseIcon,
      bottonText: context.tr("cancel"),
      cancelText: context.tr("yes"),
      showCancelButton: true,
      onPressed: () {},
      onCancel: () {
        _performLogout(context);
      },
    );
  }

  void _performLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: AppColors.primary100)),
    );

    try {
      context.read<SettingsCubit>().logoutFromSever();
      await CachNetwork.clearCache();
      getIt<tayseerSocketHelper>().disconnect();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.kRegisrationView,
        (route) => false,
      );

      showSafeSnackBar(
        context: context,
        text: context.tr("logout_success"),
        isSuccess: true,
      );
    } catch (e) {
      Navigator.pop(context);
      showSafeSnackBar(
        context: context,
        text: context.tr("logout_error"),
        isError: true,
      );
    }
  }

  void _handleSettingTap(BuildContext context, SettingItemModel setting) async {
    if (setting.onTap != null) {
      await setting.onTap!();
      return;
    }

    if (setting.id == 'invite') {
      await context.read<SettingsCubit>().shareApp(
        context.tr("share_app_message"),
        context.tr("share_app_subject"),
      );
      return;
    }

    if (setting.id == 'rate_app') {
      _showRateAppDialog();
      return;
    }

    if (setting.routeName.isNotEmpty) {
      if (setting.id == 'language') {
        final result = await Navigator.pushNamed(context, setting.routeName);
        if (result != null && result is String) {
          context.read<SettingsCubit>().updateLanguage(result);
        }
      } else {
        Navigator.pushNamed(context, setting.routeName);
      }
    }
  }

  void _showRateAppDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => RatingCubit()),
          BlocProvider(create: (_) => ToggleCubit(false)),
        ],
        child: Builder(
          builder: (innerContext) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // العنوان
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Icon(Icons.close, size: 24.w),
                      ),
                      Text(
                        context.tr("rate_app"),
                        style: Styles.textStyle20Meduim.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                      Gap(24.w),
                    ],
                  ),

                  Gap(25.h),

                  // النجوم للتقييم (قابلة للاختيار)
                  BlocBuilder<RatingCubit, int>(
                    builder: (context, rating) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              context.read<RatingCubit>().setRating(index + 1);
                            },
                            child: Icon(
                              // اختيار الأيقونة بناءً على التقييم
                              index < rating
                                  ? Icons.star_rounded
                                  : Icons.star_rounded,
                              color: index < rating
                                  ? AppColors.kprimaryColor
                                  : AppColors.secondary100,
                              size: 56.w,
                            ),
                          );
                        }),
                      );
                    },
                  ),

                  // عرض قيمة التقييم (اختياري)
                  BlocBuilder<RatingCubit, int>(
                    builder: (context, rating) {
                      if (rating > 0) {
                        return Column(
                          children: [
                            Gap(12.h),
                            Text(
                              '${context.tr("rating")}: $rating / 5',
                              style: Styles.textStyle14.copyWith(
                                color: AppColors.primary500,
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  Gap(24.h),

                  // الرسالة
                  Text(
                    context.tr("rate_app_message"),
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondary700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Gap(32.h),

                  // زر الإرسال
                  BlocBuilder<ToggleCubit, bool>(
                    builder: (loadingContext, isLoading) {
                      if (isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.kprimaryColor,
                          ),
                        );
                      }
                      return BlocBuilder<RatingCubit, int>(
                        builder: (context, rating) {
                          return CustomBotton(
                            title: context.tr("send_rating"),
                            onPressed: () async {
                              if (rating > 0) {
                                loadingContext.read<ToggleCubit>().set(true);
                                try {
                                  // Using _settingsCubit from parent widget closure
                                  await _settingsCubit.rateApp(rating);
                                  if (loadingContext.mounted) {
                                    Navigator.of(
                                      loadingContext,
                                      rootNavigator: true,
                                    ).pop();
                                  }
                                } catch (e) {
                                  if (loadingContext.mounted) {
                                    loadingContext.read<ToggleCubit>().set(
                                      false,
                                    );
                                  }
                                }
                              }
                            },
                            width: double.infinity,
                            height: 54.h,
                            useGradient: true,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
