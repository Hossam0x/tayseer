import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tayseer/core/functions/get_language_code_name.dart';
import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/core/services/paymob_config_service.dart';
import 'package:tayseer/features/shared/settings/models/setting_item_model.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_state.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/main.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/notifications/message_config.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final LocalNotification _notificationService = LocalNotification(
    navigatorKey: navigatorKey,
  );
  final UserProfileRepository _userProfileRepository;

  SettingsCubit(this._userProfileRepository) : super(SettingsInitial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (isClosed) return;
    emit(SettingsLoading());

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved language (fallback to Arabic)
      final savedLanguage = prefs.getString('app_language') ?? 'ar';

      // Get initial notification status
      final notificationStatus = await _getNotificationStatus();
      final soundStatus = AudioService.instance.soundEffectsEnabled;

      final settings = [
        SettingItemModel(
          id: 'edit_profile',
          title: 'edit_personal_data',
          iconAsset: AssetsData.icEditSettings,
          routeName: AppRouter.kEditPersonalDataView,
        ),
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
        // SettingItemModel(
        //   id: 'sound_in_app',
        //   title: 'sound_in_app',
        //   iconAsset: AssetsData.icSoundSettings,
        //   hasSwitch: true,
        //   routeName: '',
        //   switchValue: soundStatus,
        // ),
        SettingItemModel(
          id: 'events',
          title: 'events',
          iconAsset: AssetsData.eventIcon,
          routeName: AppRouter.kEventView,
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
          id: 'order_management',
          title: 'order_management',
          iconAsset: AssetsData.icOrderManagment,
          routeName: AppRouter.kOrderManagementView,
        ),
        SettingItemModel(
          id: 'packages',
          title: 'packages',
          iconAsset: AssetsData.icPackesSettinngs,
          routeName: AppRouter.kPackagesView,
        ),
        SettingItemModel(
          id: 'archive',
          title: 'archive_general',
          iconAsset: AssetsData.icArchiveSettings,
          routeName: AppRouter.kArchiveView,
        ),
        SettingItemModel(
          id: 'membership_management',
          title: 'membership_management',
          iconAsset: AssetsData.icMembershipManagement,
          routeName: AppRouter.kMembershipManagementView,
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
          routeName: AppRouter.kUpdateSessionPricingView,
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

      final referralLink = Platform.isIOS
          ? getIt<PaymobConfigService>().iosLink
          : getIt<PaymobConfigService>().androidLink;

      if (!isClosed) {
        emit(
          SettingsLoaded(
            settings: settings,
            isNotificationEnabled: notificationStatus,
            isSoundEnabled: soundStatus,
            points: 0,
            referralLink: referralLink,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) emit(SettingsError(message: 'settings_load_error'));
    }
  }

  /// تحديث اللغة المختارة + حفظها + تحديث الـ UI
  Future<void> updateLanguage(String languageCode) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', languageCode);

      final updatedSettings = currentState.settings.map((item) {
        if (item.id == 'language') {
          return item.copyWith(subtitle: getLanguageKey(languageCode));
        }
        return item;
      }).toList();

      if (!isClosed) {
        emit(
          currentState.copyWith(
            settings: updatedSettings,
            actionSuccess: "update_language_success",
            isActionKey: true,
            actionTimestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          currentState.copyWith(
            actionError: "update_language_error",
            isActionKey: true,
            actionTimestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    }
  }

  /// الحصول على حالة الاشعارات الحالية
  Future<bool> _getNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> shareApp(String message, String subject) async {
    try {
      final service = getIt<PaymobConfigService>();
      final String playStoreLink = service.androidLink;
      final String appStoreLink = service.iosLink;
      String fullMessage =
          '$message\n🤖 Android: $playStoreLink\n🍎 iOS: $appStoreLink';

      await Share.share(fullMessage, subject: subject);
    } catch (e) {
      debugPrint('❌ خطأ في المشاركة: $e');
    }
  }

  Future<void> _toggleNotificationSetting(String id, bool newValue) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    // Update both the specific field and the settings list for consistency
    final updatedSettings = currentState.settings.map((item) {
      if (item.id == id) {
        return item.copyWith(switchValue: newValue);
      }
      return item;
    }).toList();

    emit(
      currentState.copyWith(
        settings: updatedSettings,
        isNotificationEnabled: newValue,
      ),
    );

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

      // 3. تشغيل عرض الاشعارات في الخلفية
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
  Future<void> updateSwitch(String id, bool value) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    if (id == 'sound_in_app') {
      await AudioService.instance.setSoundEffectsEnabled(value);
      if (!isClosed) emit(currentState.copyWith(isSoundEnabled: value));
      return;
    }

    try {
      await _toggleNotificationSetting(id, value);

      if (!isClosed) {
        final latestState = state as SettingsLoaded;
        emit(
          latestState.copyWith(
            actionSuccess: value
                ? "notifications_enabled_success"
                : "notifications_disabled_success",
            isActionKey: true,
            actionTimestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          currentState.copyWith(
            actionError: "update_settings_error",
            isActionKey: true,
            actionTimestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    }
  }

  Future<void> rateApp(int rating) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      final result = await _userProfileRepository.rateApp(rating);

      if (!isClosed) {
        result.fold(
          (failure) {
            emit(
              currentState.copyWith(
                actionError: failure.message,
                isActionKey: false,
                actionTimestamp: DateTime.now().millisecondsSinceEpoch,
              ),
            );
          },
          (_) {
            emit(
              currentState.copyWith(
                actionSuccess: "rate_app_success",
                isActionKey: true,
                actionTimestamp: DateTime.now().millisecondsSinceEpoch,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          currentState.copyWith(
            actionError: "rate_app_error",
            isActionKey: true,
            actionTimestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    }
  }

  void clearMessages() {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(actionSuccess: null, actionError: null));
    }
  }

  /// إعادة تحميل الإعدادات كاملة (refresh)
  void refresh() {
    _loadSettings();
  }

  Future<void> logoutFromSever() async {
    await _userProfileRepository.logout(isAdvisor: true);
  }
}
