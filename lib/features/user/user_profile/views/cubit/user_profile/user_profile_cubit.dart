import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tayseer/core/functions/get_language_code_name.dart';
import 'package:tayseer/core/services/cache_cleanup_service.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/core/utils/profile_event_bus.dart';
import 'package:tayseer/features/shared/settings/models/setting_item_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_state.dart';
import 'package:tayseer/main.dart';
import 'dart:convert';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/notifications/message_config.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final LocalNotification _notificationService = LocalNotification(
    navigatorKey: navigatorKey,
  );
  final UserProfileRepository _userProfileRepository;
  late StreamSubscription<ProfileUpdateEvent> _profileSubscription;

  UserProfileCubit(this._userProfileRepository) : super(SettingsInitial()) {
    _loadInitialData();
    _listenToProfileUpdates();
  }
  static final StreamController<bool> marriageStatusStream =
      StreamController<bool>.broadcast();
  void _listenToProfileUpdates() {
    _profileSubscription = ProfileEventBus.instance.onProfileUpdated.listen((
      event,
    ) {
      // فقط نستجيب لأحداث الـ user — أحداث الـ advisor لا تخص هذه الشاشة
      if (event.userType != ProfileEventUserType.user) return;

      final currentState = state;
      if (currentState is! SettingsLoaded) return;

      final updatedProfile = currentState.userProfile?.copyWith(
        name: event.name,
        image: event.image,
        username: event.username,
      );

      if (updatedProfile != null) {
        emit(currentState.copyWith(userProfile: updatedProfile));
      }
    });
  }

  @override
  Future<void> close() {
    _profileSubscription.cancel();
    return super.close();
  }

  Future<UserProfileModel> _fetchUserProfile() async {
    try {
      final result = await _userProfileRepository.getUserProfile();
      return result.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (profile) {
          // أولوية الصورة: لو kMyProfileImage فيه صورة أحدث من الـ API، استخدمها
          final cachedImage = CachNetwork.getStringData(key: kMyProfileImage);
          final finalProfile =
              (cachedImage.isNotEmpty && cachedImage != profile.image)
              ? profile.copyWith(image: cachedImage)
              : profile;

          // حفظ في الكاش
          try {
            CachNetwork.setData(
              key: kUserProfileCache,
              value: jsonEncode(finalProfile.toJson()),
            );
          } catch (e) {
            debugPrint('❌ Error caching user profile: $e');
          }
          return finalProfile;
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _loadCachedProfile() async {
    final cachedData = CachNetwork.getStringData(key: kUserProfileCache);
    if (cachedData.isNotEmpty) {
      try {
        var profile = UserProfileModel.fromJson(jsonDecode(cachedData));

        // أولوية الصورة: لو kMyProfileImage فيه صورة أحدث، استخدمها
        final cachedImage = CachNetwork.getStringData(key: kMyProfileImage);
        if (cachedImage.isNotEmpty && cachedImage != profile.image) {
          profile = profile.copyWith(image: cachedImage);
        }

        final notificationStatus = await _getNotificationStatus();
        final isMarriageDeactivated = await _getMarriageSectionDeactivated();
        final isMarriageComplete = await _getMarriageComplete();

        final settings = await _loadSettings(
          isProfileComplete: isMarriageComplete,
          isMarriageDeactivated: isMarriageDeactivated,
        );

        emit(
          SettingsLoaded(
            settings: settings,
            userProfile: profile,
            isNotificationEnabled: notificationStatus,
            isMarriageSectionDeactivated: isMarriageDeactivated,
            isMarriageProfileComplete: isMarriageComplete,
          ),
        );
        return true;
      } catch (e) {
        debugPrint('❌ Error loading cached user profile: $e');
      }
    }
    return false;
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
      debugPrint('❌ Error fetching user profile: $e');
    }
  }

  Future<List<SettingItemModel>> _loadSettings({
    bool isProfileComplete = false,
    bool isMarriageDeactivated = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('app_language') ?? 'ar';
    final notificationStatus = await _getNotificationStatus();

    return [
      SettingItemModel(
        id: 'edit_profile',
        title: 'edit_my_profile',
        iconAsset: AssetsData.icEditSettings,
        routeName: '',
      ),
      if (!isMarriageDeactivated)
        SettingItemModel(
          id: 'edit_marriage_profile',
          title: isProfileComplete
              ? 'edit_marriage_profile'
              : 'complete_marriage_profile',
          iconAsset: AssetsData.icManagementSettings,
          routeName: '',
        ),
      SettingItemModel(
        id: 'deactivate_the_marriage_section',
        title: 'deactivate_the_marriage_section',
        iconAsset: AssetsData.ringIcon,
        routeName: '',
        hasSwitch: true,
      ),
      SettingItemModel(
        id: 'settings',
        title: 'general_settings',
        iconAsset: AssetsData.icSettingsProf,
        routeName: '',
      ),
      SettingItemModel(
        id: 'notifications',
        title: 'notifications_settings',
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
        id: 'events',
        title: 'events',
        iconAsset: AssetsData.eventIcon,
        routeName: AppRouter.kEventView,
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
        routeName: AppRouter.kUserPackagesView,
      ),
      SettingItemModel(
        id: 'user_membership_management',
        title: 'user_membership_management',
        iconAsset: AssetsData.icMembershipManagement,
        routeName: AppRouter.kUserMembershipManagementView,
      ),
      SettingItemModel(
        id: 'archive',
        title: 'archived_chats',
        iconAsset: AssetsData.icArchiveSettings,
        routeName: AppRouter.kUserArchiveChatsView,
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
        onTap: () async {
          await _shareAppLink();
        },
      ),
      SettingItemModel(
        id: 'rate_app',
        title: 'rate_the_app',
        iconAsset: AssetsData.icRateSettings,
        routeName: '',
        onTap: () async {},
      ),
      SettingItemModel(
        id: 'account_management',
        title: 'manage_account',
        iconAsset: AssetsData.icManagementSettings,
        routeName: AppRouter.kUserAccountManagementView,
      ),
    ];
  }

  static const String _kMarriageCompleteKey = 'marriage_profile_complete';

  Future<bool> _getMarriageComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kMarriageCompleteKey) ?? false;
  }

  Future<void> _saveMarriageComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMarriageCompleteKey, value);
  }

  Future<void> _loadInitialData() async {
    final hasCache = await _loadCachedProfile();

    // لا تظهر Loading إذا كان هناك بيانات كاش بالفعل (silent update)
    if (!hasCache) {
      emit(SettingsLoading());
    }

    try {
      final profile = await _fetchUserProfile();
      final isNotificationEnabled = await _getNotificationStatus();
      final isMarriageDeactivated = await _getMarriageSectionDeactivated();

      // ⭐ اقرأ من SharedPreferences مش من dataCompleted
      final isMarriageComplete = await _getMarriageComplete();

      final settings = await _loadSettings(
        isProfileComplete: isMarriageComplete,
        isMarriageDeactivated: isMarriageDeactivated,
      );

      emit(
        SettingsLoaded(
          settings: settings,
          userProfile: profile, // ⭐ profile كما هو بدون تعديل dataCompleted
          isNotificationEnabled: isNotificationEnabled,
          isMarriageSectionDeactivated: isMarriageDeactivated,
          isMarriageProfileComplete: isMarriageComplete, // ⭐
        ),
      );
    } catch (e) {
      if (state is! SettingsLoaded) {
        emit(SettingsError(message: 'error_loading_data'));
      }
    }
  }

  Future<void> updateMarriageProgress(bool isComplete) async {
    final currentState = state;
    if (currentState is! SettingsLoaded || currentState.userProfile == null)
      return;

    await _saveMarriageComplete(isComplete);

    final updatedSettings = currentState.settings.map((item) {
      if (item.id == 'edit_marriage_profile') {
        return item.copyWith(
          title: isComplete
              ? 'edit_marriage_profile'
              : 'complete_marriage_profile',
        );
      }
      return item;
    }).toList();

    // ⭐⭐⭐ تأكد إن isMarriageProfileComplete بتتبعت صح
    emit(
      currentState.copyWith(
        settings: updatedSettings,
        isMarriageProfileComplete: isComplete,
        // ⭐ مش بتبعت actionMessage عشان متشغلش الـ listener
      ),
    );
  }

  // ⭐ وظيفة جديدة: تحديث السن
  Future<void> updateAge(int newAge) async {
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
          emit(
            currentState.copyWith(
              actionMessage: 'update_age_failed',
              isActionSuccess: false,
              actionTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        },
        (updatedProfile) {
          final currentProfile = currentState.userProfile!;
          final mergedProfile = currentProfile.copyWith(
            age: updatedProfile.age != 0 ? updatedProfile.age : newAge,
          );
          emit(
            currentState.copyWith(
              userProfile: mergedProfile,
              actionMessage: "update_age_success",
              isActionSuccess: true,
              actionTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          actionMessage: "update_age_error",
          isActionSuccess: false,
          actionTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  // ⭐ وظيفة جديدة: تحديث النوع (الجندر)
  Future<void> updateGender(String newGender) async {
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
          emit(
            currentState.copyWith(
              actionMessage: 'update_gender_failed',
              isActionSuccess: false,
              actionTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        },
        (updatedProfile) {
          final currentProfile = currentState.userProfile!;
          final mergedProfile = currentProfile.copyWith(
            gender:
                updatedProfile.gender != 'male' &&
                    updatedProfile.gender != 'female'
                ? (newGender == 'ذكر' ? 'male' : 'female')
                : updatedProfile.gender,
          );
          emit(
            currentState.copyWith(
              userProfile: mergedProfile,
              actionMessage: "update_gender_success",
              isActionSuccess: true,
              actionTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          actionMessage: "update_gender_error",
          isActionSuccess: false,
          actionTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  // ⭐ وظيفة جديدة: تبديل حالة المجهول
  Future<void> toggleAnonymousStatus(bool isAnonymous) async {
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
          emit(
            currentState.copyWith(
              actionMessage: 'update_anonymous_failed',
              isActionSuccess: false,
              actionTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        },
        (_) {
          final updatedProfile = currentState.userProfile!.copyWith(
            isAnonymous: isAnonymous,
          );
          emit(
            currentState.copyWith(
              userProfile: updatedProfile,
              actionMessage: isAnonymous
                  ? "anonymous_enabled"
                  : "anonymous_disabled",
              isActionSuccess: true,
              actionTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          actionMessage: "update_anonymous_error",
          isActionSuccess: false,
          actionTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  // ⭐ وظيفة جديدة: تبديل حالة الزواج
  Future<void> toggleMarriageStatus(bool enable) async {
    final currentState = state;
    if (currentState is! SettingsLoaded || currentState.userProfile == null) {
      return;
    }

    try {
      final result = await _userProfileRepository.toggleMarriageStatus(enable);

      result.fold(
        (failure) {
          emit(
            currentState.copyWith(
              actionMessage: 'update_marriage_status_failed',
              isActionSuccess: false,
              actionTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        },
        (_) {
          final updatedProfile = currentState.userProfile!.copyWith(
            availableForMarry: enable,
          );
          emit(
            currentState.copyWith(
              userProfile: updatedProfile,
              actionMessage: enable
                  ? "marriage_status_enabled"
                  : "marriage_status_disabled",
              isActionSuccess: true,
              actionTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          actionMessage: "update_marriage_status_error",
          isActionSuccess: false,
          actionTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  // ⭐ وظيفة جديدة: تحديث تمويه الصورة
  Future<void> updateImageBlur(bool blurEnabled) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      final result = await _userProfileRepository.updateImageBlur(blurEnabled);

      result.fold(
        (failure) {
          emit(
            currentState.copyWith(
              actionMessage: 'update_blur_failed',
              isActionSuccess: false,
              actionTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        },
        (_) {
          final updatedProfile = currentState.userProfile?.copyWith(
            imageBlur: blurEnabled,
          );
          emit(
            currentState.copyWith(
              userProfile: updatedProfile,
              actionMessage: blurEnabled ? "blur_enabled" : "blur_disabled",
              isActionSuccess: true,
              actionTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          actionMessage: "update_blur_error",
          isActionSuccess: false,
          actionTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  // وظائف موجودة مسبقاً (بدون تغيير)
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

      emit(
        currentState.copyWith(
          settings: updatedSettings,
          actionMessage: "update_language_success",
          isActionSuccess: true,
          actionTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          actionMessage: "update_language_error",
          isActionSuccess: false,
          actionTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
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
      debugPrint('❌ Error sharing: $e');
    }
  }

  Future<void> _toggleNotificationSetting(String id, bool newValue) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    // Emit optimistic update
    emit(currentState.copyWith(isNotificationEnabled: newValue));

    try {
      final prefs = await SharedPreferences.getInstance();

      if (newValue) {
        await _enableNotifications();
        await prefs.setBool('notifications_enabled', true);
      } else {
        await _disableNotifications();
        await prefs.setBool('notifications_enabled', false);
      }
    } catch (e) {
      if (!isClosed) {
        emit(currentState.copyWith(isNotificationEnabled: !newValue));
      }
      rethrow;
    }
  }
  // ════════════════════════════════════════════════════════════════
  // ⭐ LOCAL CACHE HELPERS
  // ════════════════════════════════════════════════════════════════

  Future<bool> _getMarriageSectionDeactivated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kMarriageSectionDeactivatedKey) ?? false;
  }

  Future<void> _saveMarriageSectionDeactivated(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kMarriageSectionDeactivatedKey, value);
  }

  Future<void> updateSwitch(String id, bool value) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    if (id == 'notifications') {
      try {
        await _toggleNotificationSetting(id, value);

        emit(
          (state as SettingsLoaded).copyWith(
            actionMessage: value
                ? "notifications_enabled_success"
                : "notifications_disabled_success",
            isActionSuccess: true,
            actionTimestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      } catch (e) {
        emit(
          currentState.copyWith(
            actionMessage: "update_settings_error",
            isActionSuccess: false,
            actionTimestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    } else if (id == 'deactivate_the_marriage_section') {
      emit(currentState.copyWith(isMarriageSectionDeactivated: value));
      await _saveMarriageSectionDeactivated(value);

      // ✅ أضف السطر ده
      UserProfileCubit.marriageStatusStream.add(value);

      final updatedSettings = await _loadSettings(
        isProfileComplete: currentState.isMarriageProfileComplete,
        isMarriageDeactivated: value,
      );
      emit(
        currentState.copyWith(
          isMarriageSectionDeactivated: value,
          settings: updatedSettings,
        ),
      );
      debugPrint(
        '✅ Marriage section ${value ? "deactivated" : "activated"} locally',
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
      } else {
        throw Exception('Notifications permission denied');
      }
    } catch (e) {
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
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rateApp(int rating) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      final result = await _userProfileRepository.rateApp(rating);

      result.fold(
        (failure) {
          emit(
            currentState.copyWith(
              actionMessage: 'rate_app_failed',
              isActionSuccess: false,
              actionTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        },
        (_) {
          emit(
            currentState.copyWith(
              actionMessage: "rate_app_success",
              isActionSuccess: true,
              actionTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          actionMessage: "rate_app_error",
          isActionSuccess: false,
          actionTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  Future<void> logout() async {
    final currentState = state;

    try {
      await _notificationService.clearAllNotifications();

      // مسح صورة البروفايل من كاش الصور قبل الـ logout
      final profileImage = CachNetwork.getStringData(key: kMyProfileImage);
      if (profileImage.isNotEmpty) {
        try {
          CachedNetworkImage.evictFromCache(profileImage);
        } catch (_) {}
      }

      // مسح كاش البروفايل المحلي
      await CachNetwork.removeData(key: kUserProfileCache);
      await CachNetwork.removeData(key: kMyProfileImage);
      await CachNetwork.removeData(key: kMyProfileName);

      _userProfileRepository.logout();

      await CachNetwork.clearCache();
      await getIt<CacheCleanupService>().clearAllUserCache();
      getIt<tayseerSocketHelper>().disconnect();

      // ✅ ريسيت الـ Singletons عشان يتعملوا instance جديد بعد اللوجن الجديد
      if (getIt.isRegistered<HomeCubit>()) {
        getIt.resetLazySingleton<HomeCubit>();
      }
      if (getIt.isRegistered<ProfileCubit>()) {
        getIt.resetLazySingleton<ProfileCubit>();
      }

      emit(
        currentState is SettingsLoaded
            ? currentState.copyWith(
                actionMessage: "logout_success",
                isActionSuccess: true,
                actionTimestamp: DateTime.now().millisecondsSinceEpoch,
              )
            : SettingsLoaded(
                settings: [],
                actionMessage: "logout_success",
                isActionSuccess: true,
                actionTimestamp: DateTime.now().millisecondsSinceEpoch,
              ),
      );
    } catch (e) {
      if (currentState is SettingsLoaded) {
        emit(
          currentState.copyWith(
            actionMessage: "logout_error",
            isActionSuccess: false,
            actionTimestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
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
      emit(SettingsError(message: 'update_error'));
    }
  }
}
