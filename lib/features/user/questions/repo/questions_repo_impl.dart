import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/functions/upload_imageandvideo_to_api.dart';
import 'package:tayseer/features/shared/auth/model/login_data.dart';
import 'package:tayseer/features/user/questions/repo/questions_repo.dart';
import 'package:tayseer/features/user/questions/model/last_question_number_model.dart';
import 'package:tayseer/my_import.dart';

class QuestionsRepoImpl implements QuestionsRepo {
  QuestionsRepoImpl({required this.apiService});
  final ApiService apiService;

  @override
  Future<Either<Failure, UserModel>> answerQuestions({
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
          if (answerCompleted != null) 'answersCompleted': answerCompleted,
        },
        isAuth: true,
      );
      log('answer-questions:::: $response');

      final success = response['success'] ?? false;
      debugPrint('success $success');

      if (success) {
        final data = UserModel.fromJson(response['data']);
        if (answerCompleted == true) {
          await CachNetwork.setData(
            key: kuserData,
            value: jsonEncode(data.toJson()),
          );
          kCurrentUserData = data;
        }
        return right(data);
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
  Future<Either<Failure, void>> uploadPersonalInfo({
    File? image,
    List<File>? images,
  }) async {
    try {
      final map = <String, dynamic>{};

      if (image != null) {
        final fileName = image.path.split('/').last;
        map['image'] = await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        );
      }

      if (images != null && images.isNotEmpty) {
        map['images'] = [];
        for (final f in images) {
          final fileName = f.path.split('/').last;
          (map['images'] as List).add(
            await MultipartFile.fromFile(f.path, filename: fileName),
          );
        }
      }

      final response = await apiService.post(
        endPoint: '/auth/add-images',
        data: map,
        isFromData: true,
      );

      final success = response['success'] ?? false;

      if (success) {
        return right(null);
      } else {
        return left(ServerFailure(response['message'] ?? 'فشل ارسال البيانات'));
      }
    } on DioException catch (e) {
      return left(
        ServerFailure(e.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر'),
      );
    } catch (e) {
      return left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyFaceImage({required XFile image}) async {
    try {
      await apiService.post(
        endPoint: '/auth/verify-user-face',
        data: {'verifyImage': await uploadImageToApi(image)},
        isFromData: true,
      );

      // ✅ 200 = نجاح
      return const Right(null);
    } on DioException catch (e) {
      String errorMessage = 'فشل التحقق من الصورة';

      if (e.response?.data != null) {
        if (e.response?.data is Map) {
          errorMessage =
              e.response?.data['message'] ??
              e.response?.data['error'] ??
              'الرجاء التأكد من أن وجهك في الإطار وأن الإضاءة جيدة.';
        }
      }

      return Left(ServerFailure(errorMessage));
    } catch (e) {
      log('verifyFaceImage: Unknown error - $e');
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changeImageBlur() async {
    try {
      final response = await apiService.patch(
        endPoint: '/auth/change-image-blur',
      );

      final success = response['success'] ?? false;
      if (success) {
        return right(null);
      } else {
        return left(
          ServerFailure(response['message'] ?? 'فشل تغيير حالة التمويه'),
        );
      }
    } on DioException catch (e) {
      return left(
        ServerFailure(e.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر'),
      );
    } catch (e) {
      return left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> phoneNumber({
    required String phoneNumber,
    required String countryCode,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: '/user/update-phone-number',
        data: {'countryCode': countryCode, 'phone': phoneNumber},
      );

      final success = response['success'] ?? false;
      if (success) {
        return right(null);
      } else {
        return left(
          ServerFailure(response['message'] ?? 'فشل ارسال رقم الهاتف'),
        );
      }
    } on DioException catch (e) {
      return left(
        ServerFailure(e.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر'),
      );
    } catch (e) {
      return left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtp({required String otp}) async {
    try {
      final response = await apiService.post(
        endPoint: '/user/verfiy-phone',
        data: {'otp': otp},
      );

      final success = response['success'] ?? false;
      if (success) {
        return right(null);
      } else {
        return left(
          ServerFailure(response['message'] ?? 'فشل التحقق من الكود'),
        );
      }
    } on DioException catch (e) {
      return left(
        ServerFailure(e.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر'),
      );
    } catch (e) {
      return left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, LastQuestionNumber>> getLastQuestionNumber() async {
    try {
      final response = await apiService.get(
        endPoint: '/user/last-question-number',
      );

      final success = response['success'] ?? false;
      if (success) {
        try {
          final model = LastQuestionNumber.fromJson(
            response['data'] ?? {},
          );
          return right(model);
        } catch (e) {
          return left(ServerFailure('فشل تجزئة بيانات الاستجابة: $e'));
        }
      } else {
        return left(
          ServerFailure(
            response['message'] ?? 'فشل الحصول على رقم السؤال الأخير',
          ),
        );
      }
    } on DioException catch (e) {
      return left(
        ServerFailure(e.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر'),
      );
    } catch (e) {
      return left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addPreferenceFactors({
    required String minAge,
    required String maxAge,
    required String country,
    required String nationality,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: '/user/add-preference-factors',
        data: {
          'preferenceFactors': {
            'minAge': minAge,
            'maxAge': maxAge,
            'country': country,
            'nationality': nationality,
          },
        },
        isAuth: true,
      );

      log('add-preference-factors:::: $response');

      final success = response['success'] ?? false;

      if (success) {
        return right(null);
      } else {
        final message = response['message'] ?? 'فشل إرسال تفضيلات الشريك';
        return left(ServerFailure(message));
      }
    } on DioException catch (e) {
      log('addPreferenceFactors DioException: $e');
      return left(
        ServerFailure(e.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر'),
      );
    } catch (e) {
      log('addPreferenceFactors error: $e');
      return left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}
