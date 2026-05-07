import 'dart:convert';
import 'package:tayseer/core/enum/advisor_status.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/models/login_data.dart';
import 'package:tayseer/my_import.dart';

class CachNetwork {
  static late SharedPreferences sharedPref;
  static Future<void> cacheInitializaion() async {
    sharedPref = await SharedPreferences.getInstance();

    kIsUserGuest = CachNetwork.getBoolData(key: 'userGuest') ?? true;

    final userDataString = await CachNetwork.getData(key: kuserData);

    if (userDataString != null && userDataString.isNotEmpty) {
      try {
        final userDataJson = jsonDecode(userDataString) as Map<String, dynamic>;
        kCurrentUserData = UserModel.fromJson(userDataJson);
      } catch (e) {
        debugPrint('Error parsing user data from cache: $e');
        kCurrentUserData = null;
      }
    } else {
      kCurrentUserData = null;
    }

    debugPrint("kCurrentUserData is  :::::::::::: $kCurrentUserData");
    debugPrint(" id user is  :::::::::::: ${kCurrentUserData?.id}");

    final userTypeString = await CachNetwork.getData(key: kUserType);
    if (userTypeString != null && userTypeString.isNotEmpty) {
      try {
        selectedUserType = UserTypeEnum.values.firstWhere(
          (e) => e.name == userTypeString,
        );
        debugPrint('selectedUserType === $selectedUserType');
      } catch (e) {
        debugPrint('Error parsing user type from cache: $e');
        selectedUserType = UserTypeEnum.user;
      }
    } else {
      selectedUserType = UserTypeEnum.user;
    }

    // لو مفيش لغة محفوظة → استخدم لغة الجهاز (ar أو en فقط، غير كده ar)
    final savedLanguage = sharedPref.getString(kAppLanguage);
    if (savedLanguage != null) {
      selectedLanguage = savedLanguage;
    } else {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final deviceLang = deviceLocale.languageCode;
      selectedLanguage = (deviceLang == 'ar' || deviceLang == 'en')
          ? deviceLang
          : 'ar';
    }
    debugPrint("selectedLanguage initialized to: $selectedLanguage");

    final advisorStatusString = sharedPref.getString(kAdvisorStatus);
    if (advisorStatusString != null && advisorStatusString.isNotEmpty) {
      try {
        advisorStatus = AdvisorStatus.values.firstWhere(
          (e) => e.name == advisorStatusString,
        );
        debugPrint('advisorStatus === $advisorStatus');
      } catch (e) {
        debugPrint('Error parsing advisor status from cache: $e');
        advisorStatus = null;
      }
    } else {
      advisorStatus = null;
    }
  }

  static Future<bool> setData({
    required String key,
    required String value,
  }) async {
    return await sharedPref.setString(key, value);
  }

  static Future<bool> setBool({
    required String key,
    required bool value,
  }) async {
    return await sharedPref.setBool(key, value);
  }

  static Future<bool> setInt({required String key, required int value}) async {
    return await sharedPref.setInt(key, value);
  }

  static String getStringData({required String key}) {
    return sharedPref.getString(key) ?? '';
  }

  static int? getIntData({required String key}) {
    return sharedPref.getInt(key) ?? 0;
  }

  static bool? getBoolData({required String key}) {
    return sharedPref.getBool(key) ?? false;
  }

  static Future<dynamic> getData({required String key}) async {
    return sharedPref.get(key);
  }

  static Future<bool> removeData({required String key}) async {
    return await sharedPref.remove(key);
  }

  static Future<void> syncFemaleMarriedFlag() async {
    final isFemaleMarried =
        kCurrentUserData?.gender == 'female' &&
        kCurrentUserData?.socialStatus == 'F_social_married';
    await sharedPref.setBool(kIsFemaleMarriedKey, isFemaleMarried);
    if (isFemaleMarried) {
      await sharedPref.setBool(kMarriageSectionDeactivatedKey, true);
    }
  }

  /// مسح كاش الجيست والبروفايل عند الانتقال من جيست → لوجن
  /// استخدمها قبل التوجيه لشاشة التسجيل
  static Future<void> clearGuestAndProfileCache() async {
    await Future.wait([
      removeData(key: ktoken),
      removeData(key: kMyProfileImage),
      removeData(key: kMyProfileName),
      removeData(key: kGuestName),
      removeData(key: kGuestImage),
    ]);
  }

  static Future<void> setIsUserGuest(bool userType) async {
    await sharedPref.setBool("isUserGuest", userType);
    kIsUserGuest = userType;
  }

  static Future<bool> loadUserType() async {
    kIsUserGuest = sharedPref.getBool('isUserGuest') ?? false;
    return kIsUserGuest;
  }

  static Future<void> clearCache() async {
    // حفظ اللغة قبل المسح عشان متتأثرش
    final savedLanguage = sharedPref.getString(kAppLanguage);
    await sharedPref.clear();
    // إعادة حفظ اللغة بعد المسح
    if (savedLanguage != null) {
      await sharedPref.setString(kAppLanguage, savedLanguage);
    }
    kCurrentUserData = null;
    selectedUserType = UserTypeEnum.user;
    // selectedLanguage بتفضل زي ما هي - مش بنريسيتها
    kIsUserGuest = false;
  }
}
