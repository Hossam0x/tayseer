import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tayseer/core/functions/get_language_code_name.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_state.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/notifications/message_config.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final LocalNotification _notificationService = LocalNotification();
  final UserProfileRepository _userProfileRepository;

  SettingsCubit(this._userProfileRepository) : super(SettingsInitial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    emit(SettingsLoading());

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved language (fallback to Arabic)
      final savedLanguage = prefs.getString('app_language') ?? 'ar';

      // Get initial notification status
      final notificationStatus = await _getNotificationStatus();

      final settings = [
        SettingItemModel(
          id: 'notifications',
          title: 'notifications_settings',
          iconAsset: AssetsData.icNotificationSettings,
          hasSwitch: true,
          routeName: '',
          switchValue: notificationStatus,
          onTap: () async {
            // Handle switch toggle
            await _toggleNotificationSetting(
              'notifications',
              !notificationStatus,
            );
          },
        ),
        SettingItemModel(
          id: 'edit_profile',
          title: 'edit_personal_data',
          iconAsset: AssetsData.icEditSettings,
          routeName: AppRouter.kEditPersonalDataView,
        ),
        SettingItemModel(
          id: 'savers',
          title: 'wallet',
          iconAsset: AssetsData.icWalletSettings,
          routeName: AppRouter.kWalletView,
        ),
        SettingItemModel(
          id: 'language',
          title: 'app_language',
          subtitle: getLanguageKey(savedLanguage),
          iconAsset: AssetsData.icLanguageSettings,
          routeName: AppRouter.kLanguageSelectionView,
        ),
        SettingItemModel(
          id: 'packages',
          title: 'packages',
          iconAsset: AssetsData.icPackesSettinngs,
          routeName: AppRouter.kPackagesTabView,
        ),
        SettingItemModel(
          id: 'archive',
          title: 'archive_general',
          iconAsset: AssetsData.icArchiveSettings,
          routeName: AppRouter.kArchiveView,
        ),
        SettingItemModel(
          id: 'hide_story',
          title: 'hide_story_from',
          iconAsset: AssetsData.icHideSettings,
          switchValue: prefs.getBool('setting_hide_story') ?? false,
          routeName: AppRouter.kHideStoryFromView,
        ),
        SettingItemModel(
          id: 'appointments',
          title: 'appointments',
          iconAsset: AssetsData.icDatesSettings,
          routeName: AppRouter.kAppointmentsView,
        ),
        SettingItemModel(
          id: 'session_settings',
          title: 'session_settings_title',
          iconAsset: AssetsData.icDurationSettings,
          routeName: AppRouter.kSessionPricingView,
        ),
        SettingItemModel(
          id: 'workshops',
          title: 'saved_posts',
          iconAsset: AssetsData.icSavedSettings,
          routeName: AppRouter.kSavedPostsView,
        ),
        SettingItemModel(
          id: 'blocks',
          title: 'blocked_users',
          iconAsset: AssetsData.icBlockedSettings,
          routeName: AppRouter.kBlockedUsersView,
        ),
        SettingItemModel(
          id: 'help_support',
          title: 'help_and_support',
          iconAsset: AssetsData.icHelpSettings,
          routeName: AppRouter.kHelpSupportView,
        ),
        SettingItemModel(
          id: 'invite',
          title: 'invite_friend',
          iconAsset: AssetsData.icInviteSettings,
          routeName: '',
        ),
        SettingItemModel(
          id: 'rate_app',
          title: 'rate_the_app',
          iconAsset: AssetsData.icRateSettings,
          routeName: '',
        ),
        SettingItemModel(
          id: 'account_management',
          title: 'manage_account',
          iconAsset: AssetsData.icManagementSettings,
          routeName: AppRouter.kAccountManagementView,
        ),
      ];

      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsError(message: 'settings_load_error'));
    }
  }

  /// تحديث اللغة المختارة + حفظها + تحديث الـ UI
  Future<void> updateLanguage(String languageCode, BuildContext context) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', languageCode);

      // تحديث القائمة محلياً بعرض مفتاح اللغة
      final updatedSettings = currentState.settings.map((item) {
        if (item.id == 'language') {
          return item.copyWith(subtitle: getLanguageKey(languageCode));
        }
        return item;
      }).toList();

      emit(SettingsLoaded(settings: updatedSettings));

      // تحديث اللغة عالمياً لتغيير الواجهة فوراً (بعد تحديث الحالة المحلية)
      if (context.mounted) {
        context.read<LanguageCubit>().setLanguage(languageCode);
      }

      // عرض رسالة نجاح
      showSafeSnackBar(
        context: context,
        text: context.tr("update_language_success"),
        isSuccess: true,
      );
    } catch (e) {
      showSafeSnackBar(
        context: context,
        text: context.tr("update_language_error"),
        isError: true,
      );
    }
  }

  /// الحصول على حالة الاشعارات الحالية
  Future<bool> _getNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> shareApp(BuildContext context) async {
    try {
      // رابط التطبيق
      const String appLink =
          'https://play.google.com/store/apps/details?id=com.tayseer.app';
      String message = '${context.tr("share_app_message")}$appLink';

      await Share.share(message, subject: context.tr("share_app_subject"));
    } catch (e) {
      debugPrint('❌ خطأ في المشاركة: $e');
    }
  }

  /// التحكم في الاشعارات (فتح/قفل)
  Future<void> _toggleNotificationSetting(String id, bool newValue) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    // Emit optimistic update for notification toggle
    emit(currentState.copyWith(isNotificationEnabled: newValue));

    try {
      final prefs = await SharedPreferences.getInstance();

      if (newValue) {
        // Activate notifications
        await _enableNotifications();
        await prefs.setBool('notifications_enabled', true);
      } else {
        // Deactivate notifications
        await _disableNotifications();
        await prefs.setBool('notifications_enabled', false);
      }
    } catch (e) {
      // Revert on failure
      if (!isClosed) {
        emit(currentState.copyWith(isNotificationEnabled: !newValue));
      }
      rethrow;
    }
  }

  /// تفعيل الاشعارات في النظام والتطبيق
  Future<void> _enableNotifications() async {
    try {
      // 1. طلب إذن النظام
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // 2. إعادة الاشتراك في المواضيع
        await messaging.subscribeToTopic("all");

        // 3. تشغيل عرض الاشعارات في الخلفية
        if (Platform.isIOS) {
          await messaging.setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
        }

        debugPrint('✅ تم تفعيل الاشعارات بنجاح');
      } else {
        debugPrint('❌ المستخدم رفض إذن الاشعارات');
        throw Exception('تم رفض إذن الاشعارات');
      }
    } catch (e) {
      debugPrint('❌ خطأ في تفعيل الاشعارات: $e');
      rethrow;
    }
  }

  /// تعطيل الاشعارات في النظام والتطبيق
  Future<void> _disableNotifications() async {
    try {
      // 1. إلغاء الاشتراك من جميع المواضيع
      final messaging = FirebaseMessaging.instance;
      await messaging.unsubscribeFromTopic("all");

      // 2. إلغاء جميع الاشعارات المحلية
      await _notificationService.clearAllNotifications();

      // 3. تعطيل عرض الاشعارات في الخلفية
      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        );
      }

      debugPrint('✅ تم تعطيل الاشعارات بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في تعطيل الاشعارات: $e');
      rethrow;
    }
  }

  /// تحديث قيمة switch (للاستخدام العام)
  Future<void> updateSwitch(String id, bool value, BuildContext context) async {
    try {
      SnackBarService().clearAll(context);

      await _toggleNotificationSetting(id, value);

      showSafeSnackBar(
        context: context,
        text: value
            ? context.tr("notifications_enabled_success")
            : context.tr("notifications_disabled_success"),
        isSuccess: value,
        duration: const Duration(milliseconds: 1500),
      );
    } catch (e) {
      showSafeSnackBar(
        context: context,
        text: context.tr("update_settings_error"),
        isError: true,
      );
    }
  }

  Future<void> rateApp(int rating, BuildContext context) async {
    try {
      final result = await _userProfileRepository.rateApp(rating);

      if (context.mounted) {
        result.fold(
          (failure) {
            showSafeSnackBar(
              context: context,
              text: '${context.tr("rate_app_failed")}: ${failure.message}',
              isError: true,
            );
          },
          (_) {
            showSafeSnackBar(
              context: context,
              text: context.tr("rate_app_success"),
              isSuccess: true,
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        showSafeSnackBar(
          context: context,
          text: context.tr("rate_app_error"),
          isError: true,
        );
      }
    }
  }

  /// إعادة تحميل الإعدادات كاملة (refresh)
  void refresh() {
    _loadSettings();
  }
}
