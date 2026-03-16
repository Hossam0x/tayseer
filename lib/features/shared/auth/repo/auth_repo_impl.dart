import 'dart:convert';
import 'dart:developer';
import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/functions/upload_imageandvideo_to_api.dart';
import 'package:tayseer/features/shared/auth/model/guest_response_model.dart';
import 'package:tayseer/features/shared/auth/model/last_login_model.dart';
import 'package:tayseer/core/models/login_data.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../my_import.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl({required this.apiService});
  final ApiService apiService;
  Future<String> getFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      return fcmToken ?? '';
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

  // String getDeviceTimeZoneGMT() {
  //   final now = DateTime.now();
  //   final offset = now.timeZoneOffset;

  //   final hours = offset.inHours;
  //   final minutes = offset.inMinutes.remainder(60).abs();

  //   final sign = hours >= 0 ? '+' : '-';

  //   return 'GMT $sign${hours.abs()}:${minutes.toString().padLeft(2, '0')}';
  // }

  String? token;
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
          // 'timezone': getDeviceTimeZoneGMT(),
        },
      );
      log('register User response$response');

      final success = response['success'] ?? false;
      if (success) {
        final registerResponse = RegisterResponse.fromJson(response);

        // حفظ الـ token في الكاش والمتغير المحلي
        final receivedToken = registerResponse.data?.token ?? '';
        token = receivedToken;

        if (receivedToken.isNotEmpty) {
          await CachNetwork.setData(key: ktoken, value: receivedToken);
          log('✅ Token saved to cache: ${receivedToken.substring(0, 20)}...');
        }

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
      // الحصول على الـ token من الكاش
      final cachedToken = CachNetwork.getStringData(key: ktoken);

      final response = await apiService.post(
        endPoint: selectedUserType == UserTypeEnum.asConsultant
            ? "/advisor/verifyOtp"
            : '/auth/verify-account',
        data: {'otp': otp},
        headers: cachedToken.isNotEmpty
            ? {'Authorization': "Bearer $cachedToken"}
            : {},
      );
      log('otp response $response');
      final success = response['success'] ?? false;

      if (success) {
        final registerResponse = RegisterResponse.fromJson(response);

        await CachNetwork.setData(
          key: ktoken,
          value: registerResponse.data?.token ?? '',
        );
        await CachNetwork.setData(
          key: kUserType,
          value: selectedUserType == UserTypeEnum.asConsultant
              ? UserTypeEnum.asConsultant.name
              : UserTypeEnum.user.name,
        );
        await CachNetwork.setData(
          key: kuserData,
          value: jsonEncode(registerResponse.data?.user?.toJson()),
        );
        kCurrentUserData = registerResponse.data?.user;

        // ✅ حفظ الاسم والصورة في الكاش عشان الـ HomeCubit يلاقيهم فوراً
        await CachNetwork.setData(
          key: kMyProfileImage,
          value: kCurrentUserData?.image ?? '',
        );
        await CachNetwork.setData(
          key: kMyProfileName,
          value: kCurrentUserData?.name ?? '',
        );

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
  Future<Either<Failure, RegisterResponse>> authGoogle({
    required String idToken,
  }) async {
    try {
      final deviceId = await getDeviceId();
      final fcmToken = await getFcmToken();

      final platform = Platform.isAndroid ? 'android' : 'ios';

      final response = await apiService.post(
        endPoint: selectedUserType == UserTypeEnum.asConsultant
            ? '/advisor/google'
            : "/auth/google",
        data: {
          'idToken': idToken,
          'fcmToken': fcmToken,
          'deviceType': platform,
          'userType': selectedUserType == UserTypeEnum.asConsultant
              ? 'advisor'
              : 'user',
          'deviceId': deviceId,
          // 'timezone': getDeviceTimeZoneGMT(),
        },
      );
      debugPrint('authGoogle idToken $idToken');
      final success = response['success'] ?? true;

      if (success == true) {
        final authGoogleResponse = RegisterResponse.fromJson(response);
        await CachNetwork.setData(
          key: ktoken,
          value: authGoogleResponse.data?.token ?? '',
        );
        await CachNetwork.setData(
          key: kUserType,
          value: selectedUserType == UserTypeEnum.asConsultant
              ? UserTypeEnum.asConsultant.name
              : UserTypeEnum.user.name,
        );
        await CachNetwork.setData(
          key: kuserData,
          value: jsonEncode(authGoogleResponse.data?.user?.toJson()),
        );
        kCurrentUserData = authGoogleResponse.data?.user;
        await CachNetwork.setBool(key: 'userGuest', value: false);
        kIsUserGuest = false;

        // ✅ حفظ الاسم والصورة في الكاش عشان الـ HomeCubit يلاقيهم فوراً
        await CachNetwork.setData(
          key: kMyProfileImage,
          value: kCurrentUserData?.image ?? '',
        );
        await CachNetwork.setData(
          key: kMyProfileName,
          value: kCurrentUserData?.name ?? '',
        );

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
  Future<Either<Failure, RegisterResponse>> authApple({
    required String idToken,
  }) async {
    try {
      final deviceId = await getDeviceId();
      final fcmToken = await getFcmToken();

      final platform = Platform.isAndroid ? 'android' : 'ios';

      final response = await apiService.post(
        endPoint: selectedUserType == UserTypeEnum.asConsultant
            ? '/advisor/apple'
            : "/auth/apple",
        data: {
          'idToken': idToken,
          'fcmToken': fcmToken,
          'deviceType': platform,
          'userType': selectedUserType == UserTypeEnum.user
              ? 'user'
              : 'advisor',
          'deviceId': deviceId,
          // 'timezone': getDeviceTimeZoneGMT(),
        },
      );
      log('idToken$idToken');

      final success = response['success'] ?? true;

      if (success == true) {
        final authAppleResponse = RegisterResponse.fromJson(response);
        await CachNetwork.setData(
          key: ktoken,
          value: authAppleResponse.data?.token ?? '',
        );
        await CachNetwork.setData(
          key: kUserType,
          value: selectedUserType == UserTypeEnum.asConsultant
              ? UserTypeEnum.asConsultant.name
              : UserTypeEnum.user.name,
        );
        await CachNetwork.setBool(key: 'userGuest', value: false);
        await CachNetwork.setData(
          key: kuserData,
          value: jsonEncode(authAppleResponse.data?.user?.toJson()),
        );
        kCurrentUserData = authAppleResponse.data?.user;

        kIsUserGuest = false;

        // ✅ حفظ الاسم والصورة في الكاش عشان الـ HomeCubit يلاقيهم فوراً
        await CachNetwork.setData(
          key: kMyProfileImage,
          value: kCurrentUserData?.image ?? '',
        );
        await CachNetwork.setData(
          key: kMyProfileName,
          value: kCurrentUserData?.name ?? '',
        );

        return right(authAppleResponse);
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
      // الحصول على الـ token من الكاش
      final cachedToken = CachNetwork.getStringData(key: ktoken);

      final response = await apiService.post(
        endPoint: selectedUserType == UserTypeEnum.asConsultant
            ? "/advisor/reSendOtp"
            : '/auth/re-send-otp',
        headers: cachedToken.isNotEmpty
            ? {'Authorization': "Bearer $cachedToken"}
            : {},
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
  Future<Either<Failure, GuestResponseModel>> guestLogin() async {
    try {
      final response = await apiService.post(endPoint: ApiEndPoint.guestLogin);
      final success = response['success'] ?? false;
      if (success) {
        final guestResponse = GuestResponseModel.fromJson(response);
        await CachNetwork.setData(
          key: ktoken,
          value: guestResponse.data?.token ?? '',
        );
        await CachNetwork.setData(
          key: kUserType,
          value: UserTypeEnum.guest.name,
        );
        // Cache guest name and image to be used in home app bar
        await CachNetwork.setData(
          key: kGuestName,
          value: guestResponse.data?.name ?? '',
        );
        await CachNetwork.setData(
          key: kGuestImage,
          value: guestResponse.data?.image ?? '',
        );
        return right(guestResponse);
      } else {
        final message = response['message'] ?? 'فشل تسجيل الدخول كزائر.';
        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'خطأ في الاتصال بالخادم';
      return Future.value(left(ServerFailure(message)));
    } catch (error) {
      return Future.value(left(ServerFailure('حدث خطأ غير متوقع: $error')));
    }
  }

  @override
  Future<Either<Failure, RegisterResponse>> addServiceProvider({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: '/advisor/addServiceProvider',
        data: body,
      );

      final success = response['success'] ?? false;
      if (success) {
        final registerResponse = RegisterResponse.fromJson(response);
        await CachNetwork.setData(
          key: kuserData,
          value: jsonEncode(registerResponse.data?.user?.toJson()),
        );
        kCurrentUserData = registerResponse.data?.user;

        return right(registerResponse);
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

  @override
  Future<Either<Failure, RegisterResponse>> setGender({
    required String gender,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: '/user/set-gender',
        data: {'gender': gender},
        isAuth: true,
      );

      final success = response['success'] ?? false;
      if (success) {
        final registerResponse = RegisterResponse.fromJson(response);
        await CachNetwork.setData(
          key: kuserData,
          value: jsonEncode(registerResponse.data?.user?.toJson()),
        );
        kCurrentUserData = registerResponse.data?.user;
        return right(registerResponse);
      } else {
        final message = response['message'] ?? 'فشل إضافة اللغة';
        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'خطأ في الاتصال بالخادم';
      return left(ServerFailure(message));
    } catch (error) {
      debugPrint('setGender error: $error');
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }
}
