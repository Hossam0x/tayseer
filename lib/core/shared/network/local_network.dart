import 'dart:convert';
import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/auth/model/login_data.dart';
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

    ///  is Completed  Data
    if (kCurrentUserData?.completeData == true) {
      CachNetwork.setBool(key: kIsCompletedQuestions, value: true);
    } else {
      CachNetwork.setBool(key: kIsCompletedQuestions, value: false);
    }

    selectedLanguage = sharedPref.getString('app_language') ?? 'ar';
    debugPrint("selectedLanguage initialized to: $selectedLanguage");
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

  static Future<void> setIsUserGuest(bool userType) async {
    await sharedPref.setBool("isUserGuest", userType);
    kIsUserGuest = userType;
  }

  static Future<bool> loadUserType() async {
    kIsUserGuest = sharedPref.getBool('isUserGuest') ?? false;
    return kIsUserGuest;
  }
}
