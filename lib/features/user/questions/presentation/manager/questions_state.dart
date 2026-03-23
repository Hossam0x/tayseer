import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/questions/data/models/last_question_number_model.dart';

class QuestionsState {
  // ─────────────────────────────────────────────────────
  // API Operation States
  // ─────────────────────────────────────────────────────
  final CubitStates answerQuestionsState;
  final CubitStates uploadPersonalInfoState;
  final CubitStates changeImageBlurState;
  final CubitStates verifyOtpState;
  final CubitStates phoneNumberState;
  final CubitStates lastQuestionNumberState;
  final CubitStates partnerFilterState;
  final CubitStates faceVerificationState;

  // ─────────────────────────────────────────────────────
  // Data
  // ─────────────────────────────────────────────────────
  final LastQuestionNumber? lastQuestionNumberResponse;
  final String? errorMessage;
  final String? faceVerificationError;
  final File? mainImage;
  final List<File> images;
  final bool blurEnabled;

  // ─────────────────────────────────────────────────────
  // Partner Filter
  // ─────────────────────────────────────────────────────
  final RangeValues partnerAgeRange;
  final String? partnerCountry;
  final String? partnerNationality;

  // ─────────────────────────────────────────────────────
  // AI
  // ─────────────────────────────────────────────────────
  final bool isAiLoading;
  final String? aiGeneratedText;
  final String? aiErrorMessage;

  const QuestionsState({
    this.answerQuestionsState = CubitStates.initial,
    this.uploadPersonalInfoState = CubitStates.initial,
    this.changeImageBlurState = CubitStates.initial,
    this.verifyOtpState = CubitStates.initial,
    this.phoneNumberState = CubitStates.initial,
    this.lastQuestionNumberState = CubitStates.initial,
    this.partnerFilterState = CubitStates.initial,
    this.faceVerificationState = CubitStates.initial,
    this.lastQuestionNumberResponse,
    this.errorMessage,
    this.faceVerificationError,
    this.mainImage,
    this.images = const [],
    this.blurEnabled = false,
    this.partnerAgeRange = const RangeValues(22, 35),
    this.partnerCountry,
    this.partnerNationality,
    this.isAiLoading = false,
    this.aiGeneratedText,
    this.aiErrorMessage,
  });

  QuestionsState copyWith({
    CubitStates? answerQuestionsState,
    CubitStates? uploadPersonalInfoState,
    CubitStates? changeImageBlurState,
    CubitStates? verifyOtpState,
    CubitStates? phoneNumberState,
    CubitStates? lastQuestionNumberState,
    CubitStates? partnerFilterState,
    CubitStates? faceVerificationState,
    LastQuestionNumber? lastQuestionNumberResponse,
    String? errorMessage,
    String? faceVerificationError,
    File? mainImage,
    List<File>? images,
    bool? blurEnabled,
    RangeValues? partnerAgeRange,
    String? partnerCountry,
    String? partnerNationality,
    bool clearPartnerCountry = false,
    bool clearPartnerNationality = false,
    bool? isAiLoading,
    String? aiGeneratedText,
    String? aiErrorMessage,
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
      faceVerificationState:
          faceVerificationState ?? this.faceVerificationState,
      lastQuestionNumberResponse:
          lastQuestionNumberResponse ?? this.lastQuestionNumberResponse,
      errorMessage: errorMessage ?? this.errorMessage,
      faceVerificationError:
          faceVerificationError ?? this.faceVerificationError,
      mainImage: mainImage ?? this.mainImage,
      images: images ?? this.images,
      blurEnabled: blurEnabled ?? this.blurEnabled,
      partnerAgeRange: partnerAgeRange ?? this.partnerAgeRange,
      partnerCountry: clearPartnerCountry
          ? null
          : (partnerCountry ?? this.partnerCountry),
      partnerNationality: clearPartnerNationality
          ? null
          : (partnerNationality ?? this.partnerNationality),
      isAiLoading: isAiLoading ?? this.isAiLoading,
      aiGeneratedText: aiGeneratedText ?? this.aiGeneratedText,
      aiErrorMessage: aiErrorMessage ?? this.aiErrorMessage,
    );
  }

  // ─────────────────────────────────────────────────────
  // Computed Properties – Face Verification
  // ─────────────────────────────────────────────────────

  bool get isVerificationLoading =>
      faceVerificationState == CubitStates.loading;

  bool get isVerificationSuccess =>
      faceVerificationState == CubitStates.success;

  bool get isVerificationFailed => faceVerificationState == CubitStates.failure;

  bool get isVerificationInitial =>
      faceVerificationState == CubitStates.initial;

  // ─────────────────────────────────────────────────────
  // Computed Properties – Images
  // ─────────────────────────────────────────────────────

  bool get hasMainImage => mainImage != null;

  bool get hasImages => images.isNotEmpty;

  // ─────────────────────────────────────────────────────
  // Computed Properties – Partner Filter
  // ─────────────────────────────────────────────────────

  bool get isPartnerFilterLoading => partnerFilterState == CubitStates.loading;

  bool get isPartnerFilterSuccess => partnerFilterState == CubitStates.success;

  bool get isPartnerFilterFailed => partnerFilterState == CubitStates.failure;

  bool get isPartnerFilterInitial => partnerFilterState == CubitStates.initial;
}
