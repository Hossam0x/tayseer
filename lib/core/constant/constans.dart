import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/enum/male_female.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/auth/model/login_data.dart';
import 'package:tayseer/my_import.dart';

const kAppNameAr = 'تيسير';
const kAppNameEn = 'tayseer';
const kAppFont = 'ibmp';
String? selectedLanguage;
bool get isArabic => selectedLanguage == 'ar';
bool kIsUserGuest = false;
const String kbaseUrl = 'https://tayser-app.net/api/v1';
// bool kShowOnBoarding = false;
LoginData? kCurrentUserData;
Gender? selectedGender;
UserTypeEnum? selectedUserType = UserTypeEnum.user;
String phone = '201009119795';
bool get isUserAnonymous =>
    CachNetwork.getBoolData(key: kIsUserAnonymous) ?? false;
bool get isUser => selectedUserType == UserTypeEnum.user;
