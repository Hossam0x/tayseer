// lib/features/user/questions/view_model/questions_state.dart

import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/questions/model/last_question_number_model.dart';

class QuestionsState {
  final CubitStates answerQuestionsState;
  final CubitStates uploadPersonalInfoState;
  final CubitStates changeImageBlurState;
  final CubitStates verifyOtpState;
  final CubitStates phoneNumberState;
  final CubitStates lastQuestionNumberState;
  final CubitStates partnerFilterState;
  final LastQuestionNumber? lastQuestionNumberResponse;
  final String? errorMessage;

  // التحقق من الصورة الشخصية
  final CubitStates faceVerificationState;
  final String? faceVerificationError;
  final XFile? capturedFaceImage;

  // الصور للسكرين الجديدة
  final File? mainImage;
  final List<File> images;
  final bool blurEnabled;

  // بيانات فلتر البحث عن الشريك
  final RangeValues partnerAgeRange;
  final String? partnerCountry;
  final String? partnerNationality;

  const QuestionsState({
    this.answerQuestionsState = CubitStates.initial,
    this.uploadPersonalInfoState = CubitStates.initial,
    this.changeImageBlurState = CubitStates.initial,
    this.verifyOtpState = CubitStates.initial,
    this.phoneNumberState = CubitStates.initial,
    this.lastQuestionNumberState = CubitStates.initial,
    this.partnerFilterState = CubitStates.initial,
    this.lastQuestionNumberResponse,
    this.errorMessage,
    this.faceVerificationState = CubitStates.initial,
    this.faceVerificationError,
    this.capturedFaceImage,
    this.mainImage,
    this.images = const [],
    this.blurEnabled = false,
    this.partnerAgeRange = const RangeValues(22, 35),
    this.partnerCountry,
    this.partnerNationality,
  });

  QuestionsState copyWith({
    CubitStates? answerQuestionsState,
    CubitStates? uploadPersonalInfoState,
    CubitStates? changeImageBlurState,
    CubitStates? verifyOtpState,
    CubitStates? phoneNumberState,
    CubitStates? lastQuestionNumberState,
    CubitStates? partnerFilterState,
    LastQuestionNumber? lastQuestionNumberResponse,
    String? errorMessage,
    CubitStates? faceVerificationState,
    String? faceVerificationError,
    XFile? capturedFaceImage,
    File? mainImage,
    List<File>? images,
    bool? blurEnabled,
    RangeValues? partnerAgeRange,
    String? partnerCountry,
    String? partnerNationality,
    // ✅ إضافة flags للمسح
    bool clearPartnerCountry = false,
    bool clearPartnerNationality = false,
  }) {
    return QuestionsState(
      answerQuestionsState: answerQuestionsState ?? this.answerQuestionsState,
      uploadPersonalInfoState:
          uploadPersonalInfoState ?? this.uploadPersonalInfoState,
      changeImageBlurState: changeImageBlurState ?? this.changeImageBlurState,
      verifyOtpState: verifyOtpState ?? this.verifyOtpState,
      phoneNumberState: phoneNumberState ?? this.phoneNumberState,
      lastQuestionNumberState:
          lastQuestionNumberState ?? this.lastQuestionNumberState,
      partnerFilterState: partnerFilterState ?? this.partnerFilterState,
      lastQuestionNumberResponse:
          lastQuestionNumberResponse ?? this.lastQuestionNumberResponse,
      errorMessage: errorMessage ?? this.errorMessage,
      faceVerificationState:
          faceVerificationState ?? this.faceVerificationState,
      faceVerificationError:
          faceVerificationError ?? this.faceVerificationError,
      capturedFaceImage: capturedFaceImage ?? this.capturedFaceImage,
      mainImage: mainImage ?? this.mainImage,
      images: images ?? this.images,
      blurEnabled: blurEnabled ?? this.blurEnabled,
      partnerAgeRange: partnerAgeRange ?? this.partnerAgeRange,
      // ✅ إذا كان flag المسح true، اجعلها null
      partnerCountry: clearPartnerCountry
          ? null
          : (partnerCountry ?? this.partnerCountry),
      partnerNationality: clearPartnerNationality
          ? null
          : (partnerNationality ?? this.partnerNationality),
    );
  }

  // Helpers
  bool get isVerificationLoading =>
      faceVerificationState == CubitStates.loading;
  bool get isVerificationSuccess =>
      faceVerificationState == CubitStates.success;
  bool get isVerificationFailed => faceVerificationState == CubitStates.failure;
  bool get hasImage => capturedFaceImage != null;
  bool get isInitial => faceVerificationState == CubitStates.initial;
  bool get isPartnerFilterLoading => partnerFilterState == CubitStates.loading;
  bool get isPartnerFilterSuccess => partnerFilterState == CubitStates.success;
}
