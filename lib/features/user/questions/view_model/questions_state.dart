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

  // ✅ التحقق من الصورة الشخصية
  final CubitStates faceVerificationState;
  final String? faceVerificationError;

  // ✅ الصور للسكرين الجديدة
  final File? mainImage;
  final List<File> images;
  final bool blurEnabled;

  // ✅ بيانات فلتر البحث عن الشريك
  final RangeValues partnerAgeRange;
  final String? partnerCountry;
  final String? partnerNationality;
  // Ai
  final bool isAiLoading;
  final String? aiGeneratedText;
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
    // ✅ Face Verification
    this.faceVerificationState = CubitStates.initial,
    this.faceVerificationError,
    // ✅ Images
    this.mainImage,
    this.images = const [],
    this.blurEnabled = false,
    // ✅ Partner Filter
    this.partnerAgeRange = const RangeValues(22, 35),
    this.partnerCountry,
    this.partnerNationality,
    // Ai
    this.isAiLoading = false,
    this.aiGeneratedText,
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
    // ✅ Face Verification
    CubitStates? faceVerificationState,
    String? faceVerificationError,
    // ✅ Images
    File? mainImage,
    List<File>? images,
    bool? blurEnabled,
    // ✅ Partner Filter
    RangeValues? partnerAgeRange,
    String? partnerCountry,
    String? partnerNationality,
    // ✅ Flags للمسح
    bool clearPartnerCountry = false,
    bool clearPartnerNationality = false, 
    // Ai
    bool? isAiLoading,
    String? aiGeneratedText,
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
      // ✅ Face Verification
      faceVerificationState:
          faceVerificationState ?? this.faceVerificationState,
      faceVerificationError:
          faceVerificationError ?? this.faceVerificationError,
      // ✅ Images
      mainImage: mainImage ?? this.mainImage,
      images: images ?? this.images,
      blurEnabled: blurEnabled ?? this.blurEnabled,
      // ✅ Partner Filter
      partnerAgeRange: partnerAgeRange ?? this.partnerAgeRange,
      partnerCountry: clearPartnerCountry
          ? null
          : (partnerCountry ?? this.partnerCountry),
      partnerNationality: clearPartnerNationality
          ? null
          : (partnerNationality ?? this.partnerNationality),
      // Ai
      isAiLoading: isAiLoading ?? this.isAiLoading,
      aiGeneratedText: aiGeneratedText ?? this.aiGeneratedText,
    );

  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ Helpers - Face Verification
  // ═══════════════════════════════════════════════════════════════════════════

  bool get isVerificationLoading =>
      faceVerificationState == CubitStates.loading;

  bool get isVerificationSuccess =>
      faceVerificationState == CubitStates.success;

  bool get isVerificationFailed => faceVerificationState == CubitStates.failure;

  bool get isVerificationInitial =>
      faceVerificationState == CubitStates.initial;

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ Helpers - Images
  // ═══════════════════════════════════════════════════════════════════════════

  bool get hasMainImage => mainImage != null;

  bool get hasImages => images.isNotEmpty;

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ Helpers - Partner Filter
  // ═══════════════════════════════════════════════════════════════════════════

  bool get isPartnerFilterLoading => partnerFilterState == CubitStates.loading;

  bool get isPartnerFilterSuccess => partnerFilterState == CubitStates.success;

  bool get isPartnerFilterFailed => partnerFilterState == CubitStates.failure;

  bool get isPartnerFilterInitial => partnerFilterState == CubitStates.initial;
}
