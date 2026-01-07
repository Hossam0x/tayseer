import 'package:tayseer/core/enum/male_female.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/auth/model/login_data.dart';

const kAppNameAr = 'تيسير';
const kAppNameEn = 'tayseer';
const kAppFont = 'ibmp';
String? selectedLanguage;
bool get isArabic => selectedLanguage == 'ar';
bool kIsUserGuest = false;
const String kbaseUrl = 'https://tayser-app.com/api/v1';
// bool kShowOnBoarding = false;
LoginData? kCurrentUserData;
Gender? selectedGender;
UserTypeEnum? selectedUserType = UserTypeEnum.user;

String phone = '201009119795';
