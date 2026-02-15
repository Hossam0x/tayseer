import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/auth/model/guest_response_model.dart';
import 'package:tayseer/features/shared/auth/model/day_time_range_model.dart';
import 'package:tayseer/features/shared/auth/model/last_login_model.dart';

class AuthState {
  final CubitStates registerState;
  final CubitStates verifyOtpState;
  final CubitStates logoutState;
  final CubitStates signInWithGoogleState;
  final CubitStates signInWithAppleState;
  final CubitStates authGoogleState;
  final CubitStates authAppleState;
  final CubitStates guestLoginState;
  final CubitStates resendCodeState;
  final CubitStates getLastLoginState;
  final CubitStates personalDataState;
  final CubitStates addServiceProviderState;
  final CubitStates addCertificateState;
  final CubitStates addNationalImageState;
  final CubitStates addLanguageState;
  final CubitStates isAiState;

  final LastLoginResponse? lastLoginResponse;
  final GuestData? guestData;

  final String? errorMessage;
  final String? lastLoginBy;
  final String? lastLoginEmail;
  final String? fromScreen;
  final String draftText;
  final bool? verify;
  final bool? answerCompleted;
  final int? lastQuestionNumber;

  /// 🗓️ الأيام (للتوافق القديم)
  final List<String> days;

  /// 🕒 الأيام + الوقت (الجديد)
  final Map<String, DayTimeRange> availableDays;

  final List<int> durations;
  final List<String> selectedLanguages;
  final bool isThirtyMinutesSelected;
  final bool isSixtyMinutesSelected;
  final String? message;
  final String price30Min;
  final String price60Min;

  // ✅ الحقل الجديد لتحديد نوع المستخدم الحالي أثناء عملية التسجيل
  final UserTypeEnum? currentAuthUserType;

  const AuthState({
    this.registerState = CubitStates.initial,
    this.verifyOtpState = CubitStates.initial,
    this.logoutState = CubitStates.initial,
    this.signInWithGoogleState = CubitStates.initial,
    this.signInWithAppleState = CubitStates.initial,
    this.guestLoginState = CubitStates.initial,
    this.authGoogleState = CubitStates.initial,
    this.authAppleState = CubitStates.initial,
    this.resendCodeState = CubitStates.initial,
    this.getLastLoginState = CubitStates.initial,
    this.personalDataState = CubitStates.initial,
    this.addServiceProviderState = CubitStates.initial,
    this.addCertificateState = CubitStates.initial,
    this.addNationalImageState = CubitStates.initial,
    this.addLanguageState = CubitStates.initial,
    this.isAiState = CubitStates.initial,
    this.lastLoginResponse,
    this.guestData,
    this.answerCompleted,
    this.lastQuestionNumber,
    this.errorMessage,
    this.verify,
    this.fromScreen,
    this.draftText = '',
    this.lastLoginBy,
    this.lastLoginEmail,
    this.days = const [],
    this.availableDays = const {},
    this.durations = const [],
    this.selectedLanguages = const [],
    this.isThirtyMinutesSelected = false,
    this.isSixtyMinutesSelected = false,
    this.message,
    this.price30Min = '',
    this.price60Min = '',
    this.currentAuthUserType, // ✅ جديد
  });

  AuthState copyWith({
    CubitStates? registerState,
    CubitStates? verifyOtpState,
    CubitStates? logoutState,
    CubitStates? signInWithGoogleState,
    CubitStates? signInWithAppleState,
    CubitStates? authGoogleState,
    CubitStates? authAppleState,
    CubitStates? guestLoginState,
    CubitStates? resendCodeState,
    CubitStates? getLastLoginState,
    CubitStates? answerQuestionsState,
    CubitStates? personalDataState,
    CubitStates? addServiceProviderState,
    CubitStates? addCertificateState,
    CubitStates? addNationalImageState,
    CubitStates? addLanguageState,
    CubitStates? isAiState,
    LastLoginResponse? lastLoginResponse,
    bool? verify,
    bool? answerCompleted,
    int? lastQuestionNumber,
    String? errorMessage,
    String? fromScreen,
    String? draftText,
    String? lastLoginBy,
    String? lastLoginEmail,
    List<String>? days,
    Map<String, DayTimeRange>? availableDays,
    List<int>? durations,
    GuestData? guestData,
    String? selectedLanguage,
    List<String>? selectedLanguages,
    bool? isThirtyMinutesSelected,
    bool? isSixtyMinutesSelected,
    String? message,
    String? price30Min,
    String? price60Min,
    UserTypeEnum? currentAuthUserType, // ✅ جديد
  }) {
    return AuthState(
      registerState: registerState ?? this.registerState,
      verifyOtpState: verifyOtpState ?? this.verifyOtpState,
      logoutState: logoutState ?? this.logoutState,
      signInWithGoogleState:
          signInWithGoogleState ?? this.signInWithGoogleState,
      signInWithAppleState: signInWithAppleState ?? this.signInWithAppleState,
      guestLoginState: guestLoginState ?? this.guestLoginState,
      authGoogleState: authGoogleState ?? this.authGoogleState,
      authAppleState: authAppleState ?? this.authAppleState,
      resendCodeState: resendCodeState ?? this.resendCodeState,
      getLastLoginState: getLastLoginState ?? this.getLastLoginState,
      personalDataState: personalDataState ?? this.personalDataState,
      addServiceProviderState:
          addServiceProviderState ?? this.addServiceProviderState,
      addCertificateState: addCertificateState ?? this.addCertificateState,
      addNationalImageState:
          addNationalImageState ?? this.addNationalImageState,
      addLanguageState: addLanguageState ?? this.addLanguageState,
      isAiState: isAiState ?? this.isAiState,
      lastLoginResponse: lastLoginResponse ?? this.lastLoginResponse,
      errorMessage: errorMessage ?? this.errorMessage,
      lastLoginBy: lastLoginBy ?? this.lastLoginBy,
      lastLoginEmail: lastLoginEmail ?? this.lastLoginEmail,
      verify: verify ?? this.verify,
      fromScreen: fromScreen ?? this.fromScreen,
      draftText: draftText ?? this.draftText,

      answerCompleted: answerCompleted ?? this.answerCompleted,
      lastQuestionNumber: lastQuestionNumber ?? this.lastQuestionNumber,
      days: days ?? this.days,
      availableDays: availableDays ?? this.availableDays,
      durations: durations ?? this.durations,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      isThirtyMinutesSelected:
          isThirtyMinutesSelected ?? this.isThirtyMinutesSelected,
      isSixtyMinutesSelected:
          isSixtyMinutesSelected ?? this.isSixtyMinutesSelected,
      guestData: guestData ?? this.guestData,
      message: message ?? this.message,
      price30Min: price30Min ?? this.price30Min,
      price60Min: price60Min ?? this.price60Min,
      currentAuthUserType:
          currentAuthUserType ?? this.currentAuthUserType, // ✅ جديد
    );
  }

  /// 🧠 Helpers
  bool isDayEnabled(String day) {
    return availableDays.containsKey(day);
  }

  DayTimeRange? getDayRange(String day) {
    return availableDays[day];
  }

  // ✅ Helper جديد للتحقق من نوع المستخدم
  bool isUserType(UserTypeEnum type) {
    return currentAuthUserType == type;
  }

  bool get isRegularUser => currentAuthUserType == UserTypeEnum.user;
  bool get isConsultant => currentAuthUserType == UserTypeEnum.asConsultant;
}
