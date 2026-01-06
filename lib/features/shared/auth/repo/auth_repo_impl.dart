import 'dart:developer';
import 'dart:io';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/functions/upload_imageandvideo_to_api.dart';
import 'package:tayseer/features/shared/auth/model/guest_response_model.dart';
import 'package:tayseer/features/shared/auth/model/last_login_model.dart';
import 'package:tayseer/features/shared/auth/model/register_auth_google_apple_model.dart';
import 'package:tayseer/features/shared/auth/model/login_data.dart';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../my_import.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl({required this.apiService});
  final ApiService apiService;
  Future<String> getFcmToken() async {
    try {
      // Firebase Messaging removed - return empty string
      return '';
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return '';
    }
  }

  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    }
    return '';
  }

  @override
  Future<Either<Failure, RegisterResponse>> logInUser({
    required String email,
  }) async {
    try {
      final deviceId = await getDeviceId();
      final fcmToken = await getFcmToken();
      final platform = Platform.isAndroid ? 'android' : 'ios';
      debugPrint('deviceId::$deviceId');
      final response = await apiService.post(
        endPoint: selectedUserType == UserTypeEnum.asConsultant
            ? '/advisor/login'
            : '/auth/login',
        data: {
          'email': email,
          'fcmToken': fcmToken,
          'deviceId': deviceId,
          'deviceType': platform,
        },
      );
      log('register User response$response');

      final success = response['success'] ?? false;
      if (success) {
        final registerResponse = RegisterResponse.fromJson(response);
        await CachNetwork.setData(
          key: 'token',
          value: registerResponse.data?.token ?? '',
        );
        // await CachNetwork.setData(
        //   key: 'userData',
        //   value: jsonEncode(registerResponse.data?.toJson()),
        // );
        return right(registerResponse);
      } else {
        final message =
            response['message'] ?? 'حدث خطأ غير معروف أثناء إنشاء الحساب';

        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'خطأ في الاتصال بالخادم';
      return left(ServerFailure(message));
    } catch (error) {
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }

  @override
  Future<Either<Failure, RegisterResponse>> verifyOtp({
    required String otp,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: selectedUserType == UserTypeEnum.asConsultant
            ? "/advisor/verifyOtp"
            : '/auth/verify-account',
        data: {'otp': otp},
        isAuth: true,
      );
      log('otp response $response');
      final success = response['success'] ?? false;

      if (success) {
        final registerResponse = RegisterResponse.fromJson(response);
        return right(registerResponse);
      } else {
        final message = response['message'] ?? 'فشل التحقق من الكود.';
        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      return left(
        ServerFailure(
          error.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر',
        ),
      );
    } catch (error) {
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }

  @override
  Future<Either<Failure, AccountResponse>> authGoogle({
    required String idToken,
    String userType = 'user',
  }) async {
    try {
      final deviceId = await getDeviceId();
      final fcmToken = await getFcmToken();
      final platform = Platform.isAndroid ? 'android' : 'ios';

      final response = await apiService.post(
        endPoint: '/auth/google',
        data: {
          'idToken': idToken,
          'fcmToken': fcmToken,
          'deviceType': platform,
          'userType': userType,
          'deviceId': deviceId,
        },
      );

      final success = response['success'] ?? true;

      if (success == false) {
        final authGoogleResponse = AccountResponse.fromJson(response);
        await CachNetwork.setData(
          key: 'token',
          value: authGoogleResponse.data?.token ?? '',
        );
        await CachNetwork.setBool(key: 'userGuest', value: false);
        kIsUserGuest = false;
        return right(authGoogleResponse);
      } else {
        final message =
            response['message'] ?? 'حدث خطأ غير معروف أثناء إنشاء الحساب';
        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'خطأ في الاتصال بالخادم';
      return left(ServerFailure(message));
    } catch (error) {
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }

  @override
  Future<Either<Failure, AccountResponse>> authApple({
    required String idToken,
    String userType = 'user',
  }) async {
    try {
      final deviceId = await getDeviceId();
      final fcmToken = await getFcmToken();
      final platform = Platform.isAndroid ? 'android' : 'ios';

      final response = await apiService.post(
        endPoint: '/auth/apple',
        data: {
          'idToken': idToken,
          'fcmToken': fcmToken,
          'deviceType': platform,
          'userType': userType,
          'deviceId': deviceId,
        },
      );

      final success = response['success'] ?? true;

      if (success == false) {
        final authGoogleResponse = AccountResponse.fromJson(response);
        await CachNetwork.setData(
          key: 'token',
          value: authGoogleResponse.data?.token ?? '',
        );
        await CachNetwork.setBool(key: 'userGuest', value: false);
        kIsUserGuest = false;
        return right(authGoogleResponse);
      } else {
        final message =
            response['message'] ?? 'حدث خطأ غير معروف أثناء إنشاء الحساب';
        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'خطأ في الاتصال بالخادم';
      return left(ServerFailure(message));
    } catch (error) {
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp() async {
    try {
      final response = await apiService.post(
        endPoint: selectedUserType == UserTypeEnum.asConsultant
            ? "/advisor/reSendOtp"
            : '/auth/re-send-otp',
        isAuth: true,
      );

      final success = response['success'] ?? false;
      debugPrint("$success");
      if (success) {
        return right(null);
      } else {
        final message = response['message'] ?? 'فشل.';
        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      return left(
        ServerFailure(
          error.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر',
        ),
      );
    } catch (error) {
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }

  @override
  Future<Either<Failure, LastLoginResponse>> getLastLogIn() async {
    try {
      final deviceId = await getDeviceId();
      final response = await apiService.get(
        endPoint: '/auth/the-last-login',
        data: {'deviceId': deviceId},
      );

      final success = response['success'] ?? false;

      if (success) {
        final lastLoginResponse = LastLoginResponse.fromJson(response);
        return Right(lastLoginResponse);
      } else {
        final message = response['message'] ?? 'فشل في جلب آخر تسجيل دخول';
        return Left(ServerFailure(message));
      }
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'حدث خطأ أثناء الاتصال بالخادم';
      return Left(ServerFailure(message));
    } catch (e) {
      debugPrint('Error fetching last login: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

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

  @override
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
  }) async {
    try {
      // prepare multipart files by awaiting the helper functions
      final uploadedImage = await uploadImageToApi(image!);
      MultipartFile? uploadedVideo;
      if (video != null) {
        uploadedVideo = await uploadVideoToApi(video);
      }

      final response = await apiService.post(
        endPoint: '/advisor/personalData',
        isFromData: true,
        isAuth: true,
        data: {
          "name": name,
          "dateOfBirth": dateOfBirth,
          "gender": gender,
          "ProfessionalSpecialization": professionalSpecialization,
          "JobGrade": jobGrade,
          "yearsOfExperience": yearsOfExperience,
          "aboutYou": aboutYou,
          "image": uploadedImage,
          if (uploadedVideo != null) "video": uploadedVideo,
        },
      );
      log('personalDataAsConsultant response $response');
      final success = response['success'] ?? false;
      debugPrint("$success");
      if (success) {
        return right(null);
      } else {
        final message = response['message'] ?? 'فشل.';
        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      return left(
        ServerFailure(
          error.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر',
        ),
      );
    } catch (error) {
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> addCertificateAsConsultant({
    required String nameCertificate,
    required String fromWhere,
    required String date,
    required XFile image,
  }) async {
    try {
      final uploaded = await uploadImageToApi(image);
      final response = await apiService.post(
        endPoint: '/advisor/addCertificate',
        isFromData: true,
        isAuth: true,
        data: {
          "nameCertificate": nameCertificate,
          "fromWhere": fromWhere,
          "date": date,
          "image": uploaded,
        },
      );
      log('add Certificate As Consultant response $response');
      final success = response['success'] ?? false;
      debugPrint("Success $success");
      if (success) {
        return right(null);
      } else {
        final message = response['message'] ?? 'فشل.';
        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      return left(
        ServerFailure(
          error.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر',
        ),
      );
    } catch (error) {
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> addNationalImage({
    required List<XFile> nationalImages,
  }) async {
    try {
      final uploaded = await Future.wait(
        nationalImages.map((f) => uploadImageToApi(f)),
      );

      final response = await apiService.post(
        endPoint: '/advisor/addNationalImage',
        isFromData: true,
        isAuth: true,
        data: {"nationalImages": uploaded},
      );
      log('addNationalImage response $response');
      final success = response['success'] ?? false;
      debugPrint("Success $success");
      if (success) {
        return right(null);
      } else {
        final message = response['message'] ?? 'فشل.';
        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      return left(
        ServerFailure(
          error.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر',
        ),
      );
    } catch (error) {
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }

  @override
  Future<Either<Failure, GuestResponseModel>> guestLogin() {
    try {
      return apiService.post(endPoint: ApiEndPoint.guestLogin).then((response) {
        final success = response['success'] ?? false;
        if (success) {
          final guestResponse = GuestResponseModel.fromJson(response);
          return right(guestResponse);
        } else {
          final message = response['message'] ?? 'فشل تسجيل الدخول كزائر.';
          return left(ServerFailure(message));
        }
      });
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'خطأ في الاتصال بالخادم';
      return Future.value(left(ServerFailure(message)));
    } catch (error) {
      return Future.value(left(ServerFailure('حدث خطأ غير متوقع: $error')));
    }
  }

  @override
  Future<Either<Failure, void>> addServiceProvider({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: '/advisor/addServiceProvider',
        isAuth: true,
        data: body,
      );

      final success = response['success'] ?? false;
      debugPrint('addServiceProvider response: $response');
      if (success) {
        return right(null);
      } else {
        final message = response['message'] ?? 'فشل في إضافة إعدادات الخدمة';
        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'خطأ في الاتصال بالخادم';
      return left(ServerFailure(message));
    } catch (error) {
      debugPrint('Error in addServiceProvider: $error');
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> addLanguage({
    required List<String> languages,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: '/advisor/addLanguage',
        data: {'language': languages},
        isAuth: true,
      );

      final success = response['success'] ?? false;
      debugPrint('addLanguage response: $response');
      if (success) {
        return right(null);
      } else {
        final message = response['message'] ?? 'فشل إضافة اللغة';
        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'خطأ في الاتصال بالخادم';
      return left(ServerFailure(message));
    } catch (error) {
      debugPrint('addLanguage error: $error');
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }
}
