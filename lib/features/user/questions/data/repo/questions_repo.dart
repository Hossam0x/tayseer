import 'package:dartz/dartz.dart';
import 'package:tayseer/core/models/login_data.dart';
import 'package:tayseer/features/user/questions/data/models/last_question_number_model.dart';
import 'package:tayseer/my_import.dart';

abstract class QuestionsRepo {
  Future<Either<Failure, UserModel>> answerQuestions({
    required String question,
    required String questionCategoryEnum,
    required int questionNumber,
    required List<Map<String, dynamic>> answers,
    bool? answerCompleted,
  });

  Future<Either<Failure, void>> uploadPersonalInfo({
    File? image,
    List<File>? images,
  });

  Future<Either<Failure, void>> verifyFaceImage({required XFile image});

  Future<Either<Failure, void>> changeImageBlur();

  Future<Either<Failure, void>> phoneNumber({
    required String phoneNumber,
    required String countryCode,
  });

  Future<Either<Failure, void>> verifyOtp({required String otp});

  Future<Either<Failure, LastQuestionNumber>> getLastQuestionNumber();

  Future<Either<Failure, void>> addPreferenceFactors({
    required String minAge,
    required String maxAge,
    required String country,
    required String nationality,
  });
}
