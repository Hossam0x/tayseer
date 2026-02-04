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

  Future<void> fetchUserProfile() async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      final profile = await _fetchUserProfile();
      emit(currentState.copyWith(userProfile: profile));
    } catch (e) {
      debugPrint('❌ خطأ في جلب بيانات المستخدم: $e');
    }
  }

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
        id: 'edit_marriage_profile',
        title: 'إستكمال ملف الزواج',
        iconAsset: AssetsData.icManagementSettings,
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
        routeName: AppRouter.kUserArchiveChatsView,
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
        onTap: () async {},
      ),
      SettingItemModel(
        id: 'account_management',
        title: 'إدارة الحساب',
        iconAsset: AssetsData.icManagementSettings,
        routeName: AppRouter.kUserAccountManagementView,
      ),
    ];
  }

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

  // ⭐ وظيفة جديدة: تحديث السن
  Future<void> updateAge(int newAge, BuildContext context) async {
    final currentState = state;
    if (currentState is! SettingsLoaded || currentState.userProfile == null) {
      return;
    }

    try {
      final result = await _userProfileRepository.updateUserProfile(
        age: newAge,
      );

      result.fold(
        (failure) {
          showSafeSnackBar(
            context: context,
            text: 'فشل تحديث السن: ${failure.message}',
            isError: true,
          );
        },
        (updatedProfile) {
          emit(currentState.copyWith(userProfile: updatedProfile));
          showSafeSnackBar(
            context: context,
            text: 'تم تحديث السن بنجاح',
            isSuccess: true,
          );
        },
      );
    } catch (e) {
      showSafeSnackBar(
        context: context,
        text: 'حدث خطأ في تحديث السن',
        isError: true,
      );
    }
  }

  // ⭐ وظيفة جديدة: تحديث النوع (الجندر)
  Future<void> updateGender(String newGender, BuildContext context) async {
    final currentState = state;
    if (currentState is! SettingsLoaded || currentState.userProfile == null) {
      return;
    }

    try {
      final result = await _userProfileRepository.updateUserProfile(
        gender: newGender == 'ذكر' ? 'male' : 'female',
      );

      result.fold(
        (failure) {
          showSafeSnackBar(
            context: context,
            text: 'فشل تحديث النوع: ${failure.message}',
            isError: true,
          );
        },
        (updatedProfile) {
          emit(currentState.copyWith(userProfile: updatedProfile));
          showSafeSnackBar(
            context: context,
            text: 'تم تحديث النوع بنجاح',
            isSuccess: true,
          );
        },
      );
    } catch (e) {
      showSafeSnackBar(
        context: context,
        text: 'حدث خطأ في تحديث النوع',
        isError: true,
      );
    }
  }

  // ⭐ وظيفة جديدة: تبديل حالة المجهول
  Future<void> toggleAnonymousStatus(
    bool isAnonymous,
    BuildContext context,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded || currentState.userProfile == null) {
      return;
    }

    try {
      final result = await _userProfileRepository.toggleAnonymousStatus(
        isAnonymous,
      );

      result.fold(
        (failure) {
          showSafeSnackBar(
            context: context,
            text: 'فشل تحديث حالة المجهول: ${failure.message}',
            isError: true,
          );
        },
        (_) {
          final updatedProfile = currentState.userProfile!.copyWith(
            isAnonymous: isAnonymous,
          );
          emit(currentState.copyWith(userProfile: updatedProfile));

          showSafeSnackBar(
            context: context,
            text: isAnonymous ? 'تم تفعيل المجهولية' : 'تم إلغاء المجهولية',
            isSuccess: true,
          );
        },
      );
    } catch (e) {
      showSafeSnackBar(
        context: context,
        text: 'حدث خطأ في تحديث حالة المجهول',
        isError: true,
      );
    }
  }

  // ⭐ وظيفة جديدة: تبديل حالة الزواج
  Future<void> toggleMarriageStatus(bool enable, BuildContext context) async {
    final currentState = state;
    if (currentState is! SettingsLoaded || currentState.userProfile == null) {
      return;
    }

    try {
      final result = await _userProfileRepository.toggleMarriageStatus(enable);

      result.fold(
        (failure) {
          showSafeSnackBar(
            context: context,
            text: 'فشل تحديث حالة الزواج: ${failure.message}',
            isError: true,
          );
        },
        (_) {
          final updatedProfile = currentState.userProfile!.copyWith(
            availableForMarry: enable,
          );
          emit(currentState.copyWith(userProfile: updatedProfile));

          showSafeSnackBar(
            context: context,
            text: enable ? 'تم تفعيل الزواج' : 'تم إيقاف الزواج',
            isSuccess: true,
          );
        },
      );
    } catch (e) {
      showSafeSnackBar(
        context: context,
        text: 'حدث خطأ في تحديث حالة الزواج',
        isError: true,
      );
    }
  }

  // ⭐ وظيفة جديدة: تحديث تمويه الصورة
  Future<void> updateImageBlur(bool blurEnabled, BuildContext context) async {
    try {
      final result = await _userProfileRepository.updateImageBlur(blurEnabled);

      result.fold(
        (failure) {
          showSafeSnackBar(
            context: context,
            text: 'فشل تحديث إعدادات الصورة: ${failure.message}',
            isError: true,
          );
        },
        (_) {
          showSafeSnackBar(
            context: context,
            text: blurEnabled
                ? 'تم تفعيل تمويه الصورة'
                : 'تم إلغاء تمويه الصورة',
            isSuccess: true,
          );
        },
      );
    } catch (e) {
      showSafeSnackBar(
        context: context,
        text: 'حدث خطأ في تحديث إعدادات الصورة',
        isError: true,
      );
    }
  }

  // وظائف موجودة مسبقاً (بدون تغيير)
  Future<void> updateLanguage(String languageName, BuildContext context) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    final languageCode = getLanguageCode(languageName);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', languageCode);

      final updatedSettings = currentState.settings.map((item) {
        if (item.id == 'language') {
          return item.copyWith(subtitle: languageName);
        }
        return item;
      }).toList();

      emit(SettingsLoaded(settings: updatedSettings));

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

  Future<bool> _getNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> _shareAppLink() async {
    try {
      const String appLink =
          'https://play.google.com/store/apps/details?id=com.tayseer.app';
      const String message = 'جرب تطبيق تيسير الآن! 😊\n$appLink';

      await Share.share(message, subject: 'دعوة لتطبيق تيسير');
    } catch (e) {
      debugPrint('❌ خطأ في المشاركة: $e');
    }
  }

  Future<void> _toggleNotificationSetting(String id, bool newValue) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      currentState.settings.firstWhere((item) => item.id == id).switchValue;

      final updatedSettings = currentState.settings.map((item) {
        if (item.id == id) {
          return item.copyWith(switchValue: newValue);
        }
        return item;
      }).toList();

      emit(currentState.copyWith(settings: updatedSettings));

      final prefs = await SharedPreferences.getInstance();

      if (newValue) {
        await _enableNotifications();
        await prefs.setBool('notifications_enabled', true);
      } else {
        await _disableNotifications();
        await prefs.setBool('notifications_enabled', false);
      }
    } catch (e) {
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
      rethrow;
    }
  }

  Future<void> updateSwitch(String id, bool value, BuildContext context) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      SnackBarService().clearAll(context);

      final updatedSettings = currentState.settings.map((item) {
        if (item.id == id) {
          return item.copyWith(switchValue: value);
        }
        return item;
      }).toList();

      emit(currentState.copyWith(settings: updatedSettings));

      unawaited(_toggleNotificationSetting(id, value));

      showSafeSnackBar(
        context: context,
        text: value ? 'تم تفعيل الاشعارات ✅' : 'تم تعطيل الاشعارات 🔕',
        isSuccess: value ? true : false,
        duration: const Duration(milliseconds: 1500),
      );
    } catch (e) {
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

  Future<void> _enableNotifications() async {
    try {
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
        await messaging.subscribeToTopic("all");

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

  Future<void> _disableNotifications() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.unsubscribeFromTopic("all");
      await _notificationService.clearAllNotifications();

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
