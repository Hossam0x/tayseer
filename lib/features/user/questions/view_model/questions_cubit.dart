import 'package:tayseer/features/user/questions/repo/questions_repo.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';
import 'package:tayseer/my_import.dart';

class QuestionsCubit extends Cubit<QuestionsState> {
  QuestionsCubit(this._repo) : super(QuestionsState());
  final QuestionsRepo _repo;
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
}
