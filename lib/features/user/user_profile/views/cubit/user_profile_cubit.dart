import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tayseer/core/functions/get_language_code_name.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/notifications/message_config.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final LocalNotification _notificationService = LocalNotification();
  final UserProfileRepository _userProfileRepository;

  UserProfileCubit(this._userProfileRepository) : super(SettingsInitial()) {
    _loadInitialData();
  }

  // ⭐ دالة جديدة: جلب بيانات المستخدم
  Future<UserProfileModel> _fetchUserProfile() async {
    try {
      final result = await _userProfileRepository.getUserProfile();

      return result.fold((failure) {
        throw Exception(failure.message);
      }, (profile) => profile);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserProfileModel updatedProfile) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(currentState.copyWith(userProfile: updatedProfile));
  }

  // ⭐ دالة لجلب بيانات المستخدم منفردة (لـ refresh)
  Future<void> fetchUserProfile() async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      final profile = await _fetchUserProfile();
      emit(currentState.copyWith(userProfile: profile));
    } catch (e) {
      // يمكنك التعامل مع الخطأ هنا
      debugPrint('❌ خطأ في جلب بيانات المستخدم: $e');
    }
  }

  // features/user/user_profile/views/cubit/user_profile_cubit.dart
  // ⭐ تصحيح: تغيير _loadSettings لترجع List<SettingItemModel>
  Future<List<SettingItemModel>> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('app_language') ?? 'العربية';
    final notificationStatus = await _getNotificationStatus();

    return [
      SettingItemModel(
        id: 'edit_profile',
        title: 'تعديل الملف الشخصى',
        iconAsset: AssetsData.icEditSettings,
        routeName: '',
      ),
      SettingItemModel(
        id: 'settings',
        title: 'الاعدادات العامة',
        iconAsset: AssetsData.icSettingsProf,
        routeName: '',
      ),
      SettingItemModel(
        id: 'notifications',
        title: 'الاشعارات',
        iconAsset: AssetsData.icNotificationSettings,
        hasSwitch: true,
        routeName: '',
        switchValue: notificationStatus,
        onTap: () async {
          await _toggleNotificationSetting(
            'notifications',
            !notificationStatus,
          );
        },
      ),
      SettingItemModel(
        id: 'language',
        title: 'اللغة',
        subtitle: getLanguageName(savedLanguage),
        iconAsset: AssetsData.icLanguageSettings,
        routeName: AppRouter.kLanguageSelectionView,
      ),
      SettingItemModel(
        id: 'archive',
        title: 'المحادثات المؤرشفة',
        iconAsset: AssetsData.icArchiveSettings,
        routeName: AppRouter.kArchiveView,
      ),
      SettingItemModel(
        id: 'blocks',
        title: 'المحظورات',
        iconAsset: AssetsData.icBlockedSettings,
        routeName: AppRouter.kBlockedUsersView,
      ),
      SettingItemModel(
        id: 'help_support',
        title: 'المساعدة والدعم',
        iconAsset: AssetsData.icHelpSettings,
        routeName: AppRouter.kHelpSupportView,
      ),
      SettingItemModel(
        id: 'invite',
        title: 'دعوة',
        iconAsset: AssetsData.icInviteSettings,
        routeName: '',
        onTap: () async {
          await _shareAppLink();
        },
      ),
      SettingItemModel(
        id: 'rate_app',
        title: 'تقييم التطبيق',
        iconAsset: AssetsData.icRateSettings,
        routeName: '',
      ),
      SettingItemModel(
        id: 'account_management',
        title: 'إدارة الحساب',
        iconAsset: AssetsData.icManagementSettings,
        routeName: AppRouter.kUserAccountManagementView,
      ),
    ];
  }

  // ⭐ تصحيح: _loadInitialData
  Future<void> _loadInitialData() async {
    emit(SettingsLoading());

    try {
      final settings = await _loadSettings();
      final profile = await _fetchUserProfile();

      emit(SettingsLoaded(settings: settings, userProfile: profile));
    } catch (e) {
      emit(SettingsError(message: 'حدث خطأ في تحميل البيانات: $e'));
    }
  }

  // في دالة updateLanguage:
  /// تحديث اللغة المختارة + حفظها + تحديث الـ UI
  Future<void> updateLanguage(String languageName, BuildContext context) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    // الحصول على الكود من اسم اللغة
    final languageCode = getLanguageCode(languageName);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', languageCode);

      // تحديث القائمة محلياً بعرض اسم اللغة
      final updatedSettings = currentState.settings.map((item) {
        if (item.id == 'language') {
          return item.copyWith(subtitle: languageName);
        }
        return item;
      }).toList();

      emit(SettingsLoaded(settings: updatedSettings));

      // عرض رسالة نجاح
      showSafeSnackBar(
        context: context,
        text: 'تم تحديث اللغة إلى $languageName',
        isSuccess: true,
      );
    } catch (e) {
      showSafeSnackBar(
        context: context,
        text: 'حدث خطأ في تحديث اللغة ⚠️',
        isError: true,
      );
    }
  }

  /// الحصول على حالة الاشعارات الحالية
  Future<bool> _getNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> _shareAppLink() async {
    try {
      // رابط التطبيق - يمكنك تغييره
      const String appLink =
          'https://play.google.com/store/apps/details?id=com.tayseer.app';
      const String message = 'جرب تطبيق تيسير الآن! 😊\n$appLink';

      await Share.share(message, subject: 'دعوة لتطبيق تيسير');
    } catch (e) {
      debugPrint('❌ خطأ في المشاركة: $e');
    }
  }

  /// التحكم في الاشعارات (فتح/قفل)
  // تحديث دالة _toggleNotificationSetting
  Future<void> _toggleNotificationSetting(String id, bool newValue) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      // حفظ القيمة القديمة للتراجع عند الخطأ
      currentState.settings.firstWhere((item) => item.id == id).switchValue;

      // تحديث محلي أولاً لسرعة الاستجابة
      final updatedSettings = currentState.settings.map((item) {
        if (item.id == id) {
          return item.copyWith(switchValue: newValue);
        }
        return item;
      }).toList();

      emit(currentState.copyWith(settings: updatedSettings));

      final prefs = await SharedPreferences.getInstance();

      if (newValue) {
        // تفعيل الاشعارات
        await _enableNotifications();
        await prefs.setBool('notifications_enabled', true);
      } else {
        // تعطيل الاشعارات
        await _disableNotifications();
        await prefs.setBool('notifications_enabled', false);
      }
    } catch (e) {
      // عند الخطأ، إرجاع القيمة السابقة
      final currentState = state;
      if (currentState is SettingsLoaded) {
        final revertedSettings = currentState.settings.map((item) {
          if (item.id == id) {
            return item.copyWith(switchValue: !newValue);
          }
          return item;
        }).toList();

        emit(currentState.copyWith(settings: revertedSettings));
      }

      // إعادة رمي الخطأ للتعامل معه في updateSwitch
      rethrow;
    }
  }

  // تحديث دالة updateSwitch لتكون أسرع
  Future<void> updateSwitch(String id, bool value, BuildContext context) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      SnackBarService().clearAll(context);

      // تحديث فوري بدون انتظار
      final updatedSettings = currentState.settings.map((item) {
        if (item.id == id) {
          return item.copyWith(switchValue: value);
        }
        return item;
      }).toList();

      emit(currentState.copyWith(settings: updatedSettings));

      // تنفيذ العملية في الخلفية
      unawaited(_toggleNotificationSetting(id, value));

      showSafeSnackBar(
        context: context,
        text: value ? 'تم تفعيل الاشعارات ✅' : 'تم تعطيل الاشعارات 🔕',
        isSuccess: value ? true : false,
        duration: const Duration(milliseconds: 1500),
      );
    } catch (e) {
      // إرجاع القيمة الأصلية عند الخطأ
      final currentState = state;
      if (currentState is SettingsLoaded) {
        final revertedSettings = currentState.settings.map((item) {
          if (item.id == id) {
            return item.copyWith(switchValue: !value);
          }
          return item;
        }).toList();

        emit(currentState.copyWith(settings: revertedSettings));
      }

      showSafeSnackBar(
        context: context,
        text: 'حدث خطأ في تحديث الإعدادات ⚠️',
        isError: true,
      );
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

  Future<void> refresh() async {
    await _loadInitialData();
  }

  Future<void> reloadUserProfile() async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(SettingsLoading());

    try {
      final profile = await _fetchUserProfile();
      emit(currentState.copyWith(userProfile: profile));
    } catch (e) {
      emit(SettingsError(message: 'حدث خطأ في تحديث البيانات: $e'));
    }
  }
}
