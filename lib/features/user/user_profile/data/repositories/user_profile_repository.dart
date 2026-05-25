import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:tayseer/core/services/secure_token_storage.dart';
import 'package:tayseer/my_import.dart';
import '../models/user_profile_model.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfileModel>> getUserProfile();
  Future<Either<Failure, UserProfileModel>> updateUserProfile({
    String? name,
    String? username,
    String? description,
    File? imageFile,
    int? age,
    String? gender,
    void Function(int, int)? onSendProgress,
  });
  Future<Either<Failure, void>> toggleAnonymousStatus(bool isAnonymous);
  Future<Either<Failure, void>> toggleMarriageStatus(bool enable);
  Future<Either<Failure, void>> updateImageBlur(bool blurEnabled);
  Future<Either<Failure, void>> rateApp(int rating);
  Future<void> logout({bool? isAdvisor = false});
}

class UserProfileRepositoryImpl implements UserProfileRepository {
  final ApiService _apiService;

  UserProfileRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, UserProfileModel>> getUserProfile() async {
    try {
      final response = await _apiService.get(endPoint: '/user/profile');

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final profile = UserProfileModel.fromJson(data);
        return Right(profile);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل جلب ملف المستخدم'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileModel>> updateUserProfile({
    String? name,
    String? username,
    String? description,
    File? imageFile,
    int? age,
    String? gender,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (name != null) data['name'] = name;
      if (username != null) data['username'] = username;
      if (description != null) data['description'] = description;
      if (age != null) data['age'] = age;
      if (gender != null) data['gender'] = gender;

      if (imageFile != null && await imageFile.exists()) {
        final String fileName = imageFile.path.split('/').last;
        data['image'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        );
      }

      final response = await _apiService.patch(
        endPoint: '/user/update-profile',
        data: data,
        isFromData: true,
        onSendProgress: onSendProgress,
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final profile = UserProfileModel.fromJson(data);
        return Right(profile);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل تحديث الملف الشخصي'),
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'فشل الاتصال بالسيرفر';
        final errors = e.response?.data['errors'];
        // دمج الأخطاء في رسالة واحدة (مثل description: error)
        String finalMessage = message;
        if (errors != null) {
          if (errors is List) {
            finalMessage = '$message: ${errors.join(", ")}';
          } else if (errors is Map) {
            // Handle map of errors if needed
            finalMessage = '$message: $errors';
          } else {
            finalMessage = '$message: $errors';
          }
        }
        return Left(ServerFailure(finalMessage));
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleAnonymousStatus(bool isAnonymous) async {
    try {
      final response = await _apiService.post(
        endPoint: '/user/be-anonymous',
        data: {'Anonymous': isAnonymous},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل تحديث حالة المجهول'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleMarriageStatus(bool enable) async {
    try {
      final response = await _apiService.patch(
        endPoint: '/user/toggle-available-for-marry',
        data: {'avaliableForMarry': enable},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل تحديث حالة الزواج'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateImageBlur(bool blurEnabled) async {
    try {
      final response = await _apiService.patch(
        endPoint: '/auth/change-image-blur',
        data: {'blurEnabled': blurEnabled},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل تحديث إعدادات الصورة'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rateApp(int rating) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.rateApp,
        data: {'rating': rating.toString()},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل تقييم التطبيق'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> logout({bool? isAdvisor = false}) async {
    final body = await _buildLogoutBody();
    try {
      await _apiService.post(
        endPoint: isAdvisor == true ? '/advisor/logout' : '/auth/logout',
        data: body,
      );
      debugPrint('✅ logout API call succeeded');
    } catch (e) {
      // Non-fatal — we still clear local data even if the API call fails
      debugPrint('⚠️ logout API call failed (non-fatal): $e');
    }
  }

  Future<Map<String, dynamic>> _buildLogoutBody() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceId = '';
      if (Platform.isAndroid) {
        deviceId = (await deviceInfo.androidInfo).id;
      } else if (Platform.isIOS) {
        deviceId = (await deviceInfo.iosInfo).identifierForVendor ?? '';
      }
      final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';

      // refreshToken is only available after the dual-token migration login.
      // Legacy users won't have it — send empty string (backend handles gracefully).
      final refreshToken = await SecureTokenStorage.getRefreshToken() ?? '';

      debugPrint(
        '🚪 logout body — refreshToken: ${refreshToken.isEmpty ? "EMPTY (legacy user)" : "present"}',
      );

      return {
        'fcmToken': fcmToken,
        'deviceId': deviceId,
        'refreshToken': refreshToken,
      };
    } catch (_) {
      return {};
    }
  }
}
