import 'package:tayseer/core/services/cache_cleanup_service.dart';
import 'package:tayseer/core/services/chat_socket_service.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_cubit.dart';
import 'package:tayseer/features/shared/settings/models/setting_item_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_state.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/shared/rating/services/rating_service.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/settings_body.dart';
import 'package:tayseer/my_import.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final SettingsCubit _settingsCubit;

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
            listenWhen: (prev, curr) {
              if (curr is SettingsLoaded && prev is SettingsLoaded) {
                return curr.actionTimestamp != prev.actionTimestamp;
              }
              return curr is SettingsLoaded &&
                  (curr.actionSuccess != null || curr.actionError != null);
            },
            listener: _onStateChanged,
            child: SettingsBody(
              onDataChanged: () {},
              onLogout: () => _showLogoutConfirmation(context),
              onRateApp: () => _showRateAppDialog(context),
              onSettingTap: _handleSettingTap,
            ),
          ),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, SettingsState state) {
    if (state is! SettingsLoaded) return;
    if (state.actionSuccess != null) {
      if (state.actionSuccess == 'update_language_success') {
        SharedPreferences.getInstance().then((p) {
          final lang = p.getString(kAppLanguage) ?? 'ar';
          if (context.mounted) {
            context.read<LanguageCubit>().setLanguage(lang, context);
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
      _settingsCubit.clearMessages();
    } else if (state.actionError != null) {
      AppToast.error(
        context,
        state.isActionKey ? context.tr(state.actionError!) : state.actionError!,
      );
      _settingsCubit.clearMessages();
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('logout'),
      supTitle: context.tr('logout_confirmation'),
      imageUrl: AssetsData.kWoriningImage,
      bottonText: context.tr('yes'),
      cancelText: context.tr('cancel'),
      showCancelButton: true,
      onPressed: () {
        _performLogout(context);
      },
      onCancel: () {},
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Center(child: CircularProgressIndicator(color: AppColors.primary100)),
    );

    try {
      // ✅ الترتيب مهم: الـ listeners أولاً ثم الـ socket
      if (getIt.isRegistered<ChatSocketService>()) {
        getIt<ChatSocketService>().removeListeners();
      }

      // إزالة الصورة من الكاش
      final img = CachNetwork.getStringData(key: kMyProfileImage);
      if (img.isNotEmpty) {
        try {
          CachedNetworkImage.evictFromCache(img);
        } catch (_) {}
      }

      await CachNetwork.removeData(key: kAdvisorProfileCache);
      await CachNetwork.removeData(key: kMyProfileImage);
      await CachNetwork.removeData(key: kMyProfileName);

      _settingsCubit.logoutFromSever();
      await CachNetwork.clearCache();
      await getIt<CacheCleanupService>().clearAllUserCache();

      // ✅ reset بعد تنظيف كل حاجة
      getIt<tayseerSocketHelper>().reset();
      if (getIt.isRegistered<ChatListCubit>()) {
        getIt.resetLazySingleton<ChatListCubit>();
      }
      if (getIt.isRegistered<HomeCubit>())
        getIt.resetLazySingleton<HomeCubit>();
      if (getIt.isRegistered<ProfileCubit>())
        getIt.resetLazySingleton<ProfileCubit>();

      if (!context.mounted) return;
      Navigator.pop(context); // اقفل الـ loading dialog
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.kRegisrationView,
        (_) => false,
      );
      AppToast.success(context, context.tr('logout_success'));
    } catch (_) {
      if (!context.mounted) return;
      Navigator.pop(context);
      AppToast.error(context, context.tr('logout_error'));
    }
  }

  void _showRateAppDialog(BuildContext context) {
    // Trigger native review immediately — no custom dialog.
    // Backend receives rating=5 as a signal that the user engaged with the prompt.
    // Apple/Google do not return the actual star rating to the app.
    RatingService.instance.requestNativeReview().then((_) {
      _settingsCubit.rateApp(5);
      RatingService.instance.markAsRated();
    });
  }

  Future<void> _handleSettingTap(
    BuildContext context,
    SettingItemModel setting,
  ) async {
    if (setting.onTap != null) {
      await setting.onTap!();
      return;
    }
    switch (setting.id) {
      case 'invite':
        await _settingsCubit.shareApp(
          context.tr('share_app_message'),
          context.tr('share_app_subject'),
        );
        return;
      case 'rate_app':
        _showRateAppDialog(context);
        return;
    }
    if (setting.routeName.isEmpty) return;
    if (setting.id == 'language') {
      final result = await Navigator.pushNamed(context, setting.routeName);
      if (result is String && context.mounted) {
        _settingsCubit.updateLanguage(result);
      }
    } else {
      await Navigator.pushNamed(context, setting.routeName);
    }
  }
}
