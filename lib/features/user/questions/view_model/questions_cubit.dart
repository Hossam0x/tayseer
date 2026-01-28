import 'package:tayseer/features/user/questions/repo/questions_repo.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';
import 'package:tayseer/my_import.dart';

class QuestionsCubit extends Cubit<QuestionsState> {
  QuestionsCubit(this._repo) : super(const QuestionsState());
  final QuestionsRepo _repo;

  // -------------------------------------
  // الصور للسكرين الجديدة
  // -------------------------------------

  void setMainImage(File image) {
    emit(state.copyWith(mainImage: image));
  }

  void setImages(List<File> images) {
    final copied = List<File>.from(images);
    emit(state.copyWith(images: copied));
  }

  // -------------------------------------
  // uploadPersonalInfo
  // -------------------------------------

  Future<void> uploadPersonalInfo({File? image, List<File>? images}) async {
    emit(state.copyWith(uploadPersonalInfoState: CubitStates.loading));

    try {
      final response = await _repo.uploadPersonalInfo(
        image: image,
        images: images,
      );

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              uploadPersonalInfoState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );

          emit(
            state.copyWith(
              uploadPersonalInfoState: CubitStates.initial,
              errorMessage: null,
            ),
          );
        },
        (_) {
          setMainImage(image!);
          setImages(images!);
          emit(state.copyWith(uploadPersonalInfoState: CubitStates.success));
          emit(state.copyWith(uploadPersonalInfoState: CubitStates.initial));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          uploadPersonalInfoState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // -------------------------------------
  // answer questions
  // -------------------------------------

  Future<void> sendAnswerQuestions({
    required String question,
    required String questionCategoryEnum,
    required int questionNumber,
    required List<Map<String, dynamic>> answers,
    bool? answerCompleted,
  }) async {
    emit(state.copyWith(answerQuestionsState: CubitStates.loading));

    try {
      final response = await _repo.answerQuestions(
        question: question,
        questionCategoryEnum: questionCategoryEnum,
        questionNumber: questionNumber,
        answers: answers,
        answerCompleted: answerCompleted,
      );

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              answerQuestionsState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
          emit(
            state.copyWith(
              answerQuestionsState: CubitStates.initial,
              errorMessage: null,
            ),
          );
        },
        (_) {
          emit(state.copyWith(answerQuestionsState: CubitStates.success));
          emit(state.copyWith(answerQuestionsState: CubitStates.initial));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          answerQuestionsState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // -------------------------------------
  // verifyFace
  // -------------------------------------

  Future<void> verifyFaceImage({required XFile image}) async {
    emit(
      state.copyWith(
        faceVerificationState: CubitStates.loading,
        capturedFaceImage: image,
        faceVerificationError: null,
      ),
    );

    try {
      final response = await _repo.verifyFaceImage(image: image);

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              faceVerificationState: CubitStates.failure,
              faceVerificationError: failure.message,
            ),
          );
        },
        (_) {
          emit(
            state.copyWith(
              faceVerificationState: CubitStates.success,
              faceVerificationError: null,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          faceVerificationState: CubitStates.failure,
          faceVerificationError: e.toString(),
        ),
      );
    }
  }

  void resetFaceVerification() {
    emit(
      state.copyWith(
        faceVerificationState: CubitStates.initial,
        faceVerificationError: null,
        capturedFaceImage: null,
      ),
    );
  }

  void setCapturedFaceImage(XFile? image) {
    emit(
      state.copyWith(
        capturedFaceImage: image,
        faceVerificationState: CubitStates.initial,
        faceVerificationError: null,
      ),
    );
  }

  void clearCapturedImage() {
    emit(
      state.copyWith(
        capturedFaceImage: null,
        faceVerificationState: CubitStates.initial,
        faceVerificationError: null,
      ),
    );
  }

  // -------------------------------------
  // change image blur
  // -------------------------------------

  Future<void> changeImageBlur() async {
    emit(state.copyWith(changeImageBlurState: CubitStates.loading));

    try {
      final result = await _repo.changeImageBlur();
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              changeImageBlurState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (_) {
          emit(state.copyWith(changeImageBlurState: CubitStates.success));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          changeImageBlurState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }

    emit(state.copyWith(changeImageBlurState: CubitStates.initial));
  }
}
