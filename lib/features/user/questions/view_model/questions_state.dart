import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/questions/model/last_question_number_model.dart';

class QuestionsState {
  final CubitStates answerQuestionsState;
  final CubitStates uploadPersonalInfoState;
  final CubitStates changeImageBlurState;
  final CubitStates verifyOtpState;
  final CubitStates phoneNumberState;
  final CubitStates lastQuestionNumberState;
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

  const QuestionsState({
    this.answerQuestionsState = CubitStates.initial,
    this.uploadPersonalInfoState = CubitStates.initial,
    this.changeImageBlurState = CubitStates.initial,
    this.verifyOtpState = CubitStates.initial,
    this.phoneNumberState = CubitStates.initial,
    this.lastQuestionNumberState = CubitStates.initial,
    this.lastQuestionNumberResponse,
    this.errorMessage,
    this.faceVerificationState = CubitStates.initial,
    this.faceVerificationError,
    this.capturedFaceImage,

    // إضافات جديدة
    this.mainImage,
    this.images = const [],
    this.blurEnabled = false,
  });

  QuestionsState copyWith({
    CubitStates? answerQuestionsState,
    CubitStates? uploadPersonalInfoState,
    CubitStates? changeImageBlurState,
    CubitStates? verifyOtpState,
    CubitStates? phoneNumberState,
    CubitStates? lastQuestionNumberState,
    LastQuestionNumber? lastQuestionNumberResponse,
    String? errorMessage,
    CubitStates? faceVerificationState,
    String? faceVerificationError,
    XFile? capturedFaceImage,

    // إضافات جديدة
    File? mainImage,
    List<File>? images,
    bool? blurEnabled,
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
        lastQuestionNumberResponse:
          lastQuestionNumberResponse ?? this.lastQuestionNumberResponse,
      errorMessage: errorMessage ?? this.errorMessage,
      faceVerificationState:
          faceVerificationState ?? this.faceVerificationState,
      faceVerificationError:
          faceVerificationError ?? this.faceVerificationError,
      capturedFaceImage: capturedFaceImage ?? this.capturedFaceImage,

      // إضافات
      mainImage: mainImage ?? this.mainImage,
      images: images ?? this.images,
      blurEnabled: blurEnabled ?? this.blurEnabled,
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
}
