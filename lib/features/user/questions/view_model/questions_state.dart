import 'package:tayseer/my_import.dart';

class QuestionsState {
  final CubitStates answerQuestionsState;
  final String? errorMessage;
  const QuestionsState({
    this.answerQuestionsState = CubitStates.initial,
    this.errorMessage,
  });
  QuestionsState copyWith({
    CubitStates? answerQuestionsState,
    String? errorMessage,
  }) {
    return QuestionsState(
      answerQuestionsState: answerQuestionsState ?? this.answerQuestionsState,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
