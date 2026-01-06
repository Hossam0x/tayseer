import 'dart:convert';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/auth/model/login_data.dart';
import 'package:tayseer/my_import.dart';

class CachNetwork {
  static late SharedPreferences sharedPref;
  static cacheInitializaion() async {
    sharedPref = await SharedPreferences.getInstance();

    // kShowOnBoarding = await CachNetwork.getBoolData(key: 'onBoarding') ?? true;

    kIsUserGuest = await CachNetwork.getBoolData(key: 'userGuest') ?? true;

    final userDataString = await CachNetwork.getData(key: 'userData');

    if (userDataString != null) {
      final userDataJson = jsonDecode(userDataString);
      kCurrentUserData = LoginData.fromJson(userDataJson);
    }

    final userTypeString = await CachNetwork.getData(key: 'user_type');

    if (userTypeString != null) {
      selectedUserType = UserTypeEnum.values.firstWhere(
        (e) => e.name == userTypeString,
      );
      debugPrint('selectedUserType===$selectedUserType');
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

  static Future<bool?> getBoolData({required String key}) async {
    return await sharedPref.getBool(key) ?? false;
  }

  static Future<dynamic> getData({required String key}) async {
    return await sharedPref.get(key);
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
