import 'package:flutter/foundation.dart';
import 'package:tayseer/core/enum/advisor_status.dart';
import 'package:tayseer/core/enum/male_female.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/models/login_data.dart';
import 'package:tayseer/my_import.dart';

const kAppNameAr = 'تيسير';
const kAppNameEn = 'tayseer';
const kAppFont = 'ibmp';
String? selectedLanguage;
bool get isArabic => selectedLanguage == 'ar';
bool kIsUserGuest = false;
String get kbaseUrl => kReleaseMode
    ? 'https://tayser-app.net/api/v1'
    : 'https://dev.tayser-app.net/api/v1';
// bool kShowOnBoarding = false;
UserModel? kCurrentUserData;
Gender? selectedGender;
UserTypeEnum? selectedUserType = UserTypeEnum.user;
String phone = '201009119795';
bool get isUserAnonymous =>
    CachNetwork.getBoolData(key: kIsUserAnonymous) ?? false;
bool get isUser => selectedUserType == UserTypeEnum.user;
bool get isAdvisor => selectedUserType == UserTypeEnum.asConsultant;
bool get isGuest => selectedUserType == UserTypeEnum.guest;
bool get isConsultant => selectedUserType == UserTypeEnum.asConsultant;

AdvisorStatus? advisorStatus;

bool get canAct {
  if (isGuest) return false;
  if (isAdvisor) {
    if (advisorStatus == AdvisorStatus.approved) {
      return true;
    } else {
      return false;
    }
  }
  return true;
}
