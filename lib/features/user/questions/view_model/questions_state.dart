// questions_state.dart

import 'package:tayseer/my_import.dart';

class QuestionsState {
  final CubitStates answerQuestionsState;
  final CubitStates uploadPersonalInfoState;
  final String? errorMessage;

  // ✅ حالات التحقق من الصورة الشخصية
  final CubitStates faceVerificationState;
  final String? faceVerificationError;
  final XFile? capturedFaceImage;

  const QuestionsState({
    this.answerQuestionsState = CubitStates.initial,
    this.uploadPersonalInfoState = CubitStates.initial,
    this.errorMessage,
    this.faceVerificationState = CubitStates.initial,
    this.faceVerificationError,
    this.capturedFaceImage,
  });

  QuestionsState copyWith({
    CubitStates? answerQuestionsState,
    CubitStates? uploadPersonalInfoState,
    String? errorMessage,
    CubitStates? faceVerificationState,
    String? faceVerificationError,
    XFile? capturedFaceImage,
  }) {
    return QuestionsState(
      answerQuestionsState: answerQuestionsState ?? this.answerQuestionsState,
      uploadPersonalInfoState:
          uploadPersonalInfoState ?? this.uploadPersonalInfoState,
      errorMessage: errorMessage ?? this.errorMessage,
      faceVerificationState:
          faceVerificationState ?? this.faceVerificationState,
      faceVerificationError:
          faceVerificationError ?? this.faceVerificationError,
      capturedFaceImage: capturedFaceImage ?? this.capturedFaceImage,
    );
  }

  // ✅ Helper methods (محدثة)
  bool get isVerificationLoading =>
      faceVerificationState == CubitStates.loading;

  // ✅ النجاح = 200 = success state
  bool get isVerificationSuccess =>
      faceVerificationState == CubitStates.success;

  // ✅ الفشل = 400 = failure state
  bool get isVerificationFailed => faceVerificationState == CubitStates.failure;

  bool get hasImage => capturedFaceImage != null;

  bool get isInitial => faceVerificationState == CubitStates.initial;
}
