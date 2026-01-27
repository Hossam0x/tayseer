import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';

abstract class QuestionsRepo {
  Future<Either<Failure, void>> answerQuestions({
    required String question,
    required String questionCategoryEnum,
    required int questionNumber,
    required List<Map<String, dynamic>> answers,
    bool? answerCompleted,
  });
}
