import 'package:tayseer/features/shared/auth/model/guest_response_model.dart';
import 'package:tayseer/features/shared/auth/model/last_login_model.dart';
import 'package:tayseer/features/shared/auth/model/register_auth_google_apple_model.dart';
import 'package:tayseer/features/shared/auth/model/login_data.dart';
import 'package:dartz/dartz.dart';

import '../../../../my_import.dart';

abstract class AuthRepo {
  Future<Either<Failure, RegisterResponse>> verifyOtp({required String otp});

  Future<Either<Failure, RegisterResponse>> logInUser({required String email});
  Future<Either<Failure, GuestResponseModel>> guestLogin();
  Future<Either<Failure, AccountResponse>> authGoogle({
    required String idToken,
    String userType = 'user',
  });
  Future<Either<Failure, AccountResponse>> authApple({
    required String idToken,
    String userType = 'user',
  });
  Future<Either<Failure, void>> resendOtp();
  Future<Either<Failure, LastLoginResponse>> getLastLogIn();
  Future<Either<Failure, void>> answerQuestions({
    required String question,
    required String questionCategoryEnum,
    required int questionNumber,
    required List<Map<String, dynamic>> answers,
    bool? answerCompleted,
  });
  Future<Either<Failure, void>> personalDataAsConsultant({
    required String name,
    required String dateOfBirth,
    required String gender,
    required String professionalSpecialization,
    required String jobGrade,
    required String yearsOfExperience,
    required String aboutYou,
    required XFile? image,
    required XFile? video,
  });

  Future<Either<Failure, void>> addCertificateAsConsultant({
    required String nameCertificate,
    required String fromWhere,
    required String date,
    required XFile image,
  });

  Future<Either<Failure, void>> addNationalImage({
    required List<XFile> nationalImages,
  });

  Future<Either<Failure, void>> addServiceProvider({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, void>> addLanguage({required List<String> languages});
}
