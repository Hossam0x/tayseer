import 'package:tayseer/core/services/cache_cleanup_service.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_state.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/referral_share_card.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/settings/settings_item_widget.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/settings/settings_logout_button.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/settings/settings_rate_dialog.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/settings/settings_error_view.dart';
import 'package:tayseer/my_import.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late SettingsCubit _settingsCubit;
  bool _hasDataChanged = false;

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

  void _markDataChanged() => _hasDataChanged = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) Navigator.of(context).pop(_hasDataChanged);
      },
      child: BlocProvider.value(
        value: _settingsCubit,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AdvisorBackground(
            child: BlocListener<SettingsCubit, SettingsState>(
              listenWhen: (previous, current) {
                if (current is SettingsLoaded && previous is SettingsLoaded) {
                  return current.actionTimestamp != previous.actionTimestamp;
                }
                if (current is SettingsLoaded &&
                    (current.actionSuccess != null ||
                        current.actionError != null)) {
                  return true;
                }
                return false;
              },
              listener: (context, state) {
                if (state is! SettingsLoaded) return;
                if (state.actionSuccess != null) {
                  _markDataChanged();
                  if (state.actionSuccess == "update_language_success") {
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
                    AppToast.success(
                      context,
                      state.isActionKey
                          ? context.tr(state.actionSuccess!)
                          : state.actionSuccess!,
                    );
                  }
                  context.read<SettingsCubit>().clearMessages();
                } else if (state.actionError != null) {
                  AppToast.error(
                    context,
                    state.isActionKey
                        ? context.tr(state.actionError!)
                        : state.actionError!,
                  );
                  context.read<SettingsCubit>().clearMessages();
                }
              },
              child: _SettingsBody(
                onDataChanged: _markDataChanged,
                onLogout: () => _showLogoutConfirmation(context),
                onRateApp: () => _showRateAppDialog(context),
                onSettingTap: (setting) => _handleSettingTap(context, setting),
              ),
            ),
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
      onCancel: () => _performLogout(context),
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
      final profileImage = CachNetwork.getStringData(key: kMyProfileImage);
      if (profileImage.isNotEmpty) {
        try {
          CachedNetworkImage.evictFromCache(profileImage);
        } catch (_) {}
      }

      await CachNetwork.removeData(key: kAdvisorProfileCache);
      await CachNetwork.removeData(key: kMyProfileImage);
      await CachNetwork.removeData(key: kMyProfileName);

      _settingsCubit.logoutFromSever();
      await CachNetwork.clearCache();
      await getIt<CacheCleanupService>().clearAllUserCache();
      getIt<tayseerSocketHelper>().disconnect();

      if (getIt.isRegistered<HomeCubit>())
        getIt.resetLazySingleton<HomeCubit>();
      if (getIt.isRegistered<ProfileCubit>()) {
        getIt.resetLazySingleton<ProfileCubit>();
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.kRegisrationView,
        (route) => false,
      );
      AppToast.success(context, context.tr("logout_success"));
    } catch (e) {
      Navigator.pop(context);
      AppToast.error(context, context.tr("logout_error"));
    }
  }

  void _showRateAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SettingsRateDialog(settingsCubit: _settingsCubit),
    );
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
      _showRateAppDialog(context);
      return;
    }

    if (setting.routeName.isNotEmpty) {
      if (setting.id == 'language') {
        final result = await Navigator.pushNamed(context, setting.routeName);
        if (result != null && result is String) {
          _markDataChanged();
          if (context.mounted) {
            context.read<SettingsCubit>().updateLanguage(result);
          }
        }
      } else {
        final result = await Navigator.pushNamed(context, setting.routeName);
        if (result != null && result != false) _markDataChanged();
      }
    }
  }
}

class _SettingsBody extends StatelessWidget {
  final VoidCallback onDataChanged;
  final VoidCallback onLogout;
  final VoidCallback onRateApp;
  final void Function(SettingItemModel) onSettingTap;

  const _SettingsBody({
    required this.onDataChanged,
    required this.onLogout,
    required this.onRateApp,
    required this.onSettingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 105.h,
          child: DecoratedBox(
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
                    return SettingsErrorView(message: state.message);
                  }

                  if (state is SettingsLoaded) {
                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 20.w,
                              right: 20.w,
                              top: 10.h,
                            ),
                            child: ReferralShareCard(
                              points: state.points,
                              referralLink: state.referralLink,
                              onShare: () {
                                context.read<SettingsCubit>().shareApp(
                                  context.tr("share_app_message"),
                                  context.tr("share_app_subject"),
                                );
                              },
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              if (index.isOdd) {
                                return Divider(
                                  color: AppColors.secondary100,
                                  height: 1,
                                );
                              }
                              final item = state.settings[index ~/ 2];
                              return SettingsItemWidget(
                                setting: item,
                                onTap: () => onSettingTap(item),
                                onDataChanged: onDataChanged,
                              );
                            }, childCount: state.settings.length * 2),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SettingsLogoutButton(onTap: onLogout),
                        ),
                        SliverToBoxAdapter(child: Gap(30.h)),
                      ],
                    );
                  }

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
}
