import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/questions/repo/questions_repo.dart';
import 'package:tayseer/my_import.dart';

class QuestionsRepoImpl implements QuestionsRepo {
  QuestionsRepoImpl({required this.apiService});
  final ApiService apiService;
  @override
  Future<Either<Failure, void>> answerQuestions({
    required String question,
    required String questionCategoryEnum,
    required int questionNumber,
    required List<Map<String, dynamic>> answers,
    bool? answerCompleted,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: '/answer-questions',
        data: {
          'question': question,
          'questionCategory': questionCategoryEnum,
          'questionNumber': questionNumber,
          'answers': answers,
          if (answerCompleted != null) 'answerCompleted': answerCompleted,
        },
        isAuth: true,
      );
      log('answer-questions:::: $response');

      final success = response['success'] ?? false;
      debugPrint('success $success');

      if (success) {
        return right(null);
      } else {
        final message = response['message'] ?? 'فشل ارسال الاجابه';
        debugPrint('message $message');

        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      debugPrint('DioException error $error');
      return left(
        ServerFailure(
          error.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر',
        ),
      );
    } catch (error) {
      debugPrint(' error $error');

      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }
}
