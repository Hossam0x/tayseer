import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/functions/upload_imageandvideo_to_api.dart';
import 'package:tayseer/core/models/login_data.dart';
import 'package:tayseer/features/user/questions/data/repo/questions_repo.dart';
import 'package:tayseer/features/user/questions/data/models/last_question_number_model.dart';
import 'package:tayseer/my_import.dart';

class QuestionsRepoImpl implements QuestionsRepo {
  QuestionsRepoImpl({required this.apiService});
  final ApiService apiService;

  String _normalizeSocialStatus(String? value) {
    if (value == 'social_single' || value == 'F_social_single') {
      return 'single';
    }
    return value ?? '';
  }

  // ─────────────────────────────────────────────────────
  // Shared error handling wrapper
  // ─────────────────────────────────────────────────────

  /// Wraps any API call with consistent error handling.
  ///
  /// Catches [DioException] and generic exceptions, returning
  /// appropriate [ServerFailure] messages.
  Future<Either<Failure, T>> _safeApiCall<T>(
    Future<Either<Failure, T>> Function() apiCall,
  ) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      return left(
        ServerFailure(e.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر'),
      );
    } catch (e) {
      return left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  // ─────────────────────────────────────────────────────
  // Answer Questions
  // ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserModel>> answerQuestions({
    required String question,
    required String questionCategoryEnum,
    required int questionNumber,
    required List<Map<String, dynamic>> answers,
    bool? answerCompleted,
  }) {
    return _safeApiCall(() async {
      final normalizedAnswers = questionCategoryEnum == 'socialStatus'
          ? answers.map((answer) {
              final normalized = _normalizeSocialStatus(
                answer['answer']?.toString(),
              );
              return {...answer, 'answer': normalized};
            }).toList()
          : answers;

      final response = await apiService.post(
        endPoint: '/answer-questions',
        data: {
          'question': question,
          'questionCategory': questionCategoryEnum,
          'questionNumber': questionNumber,
          'answers': normalizedAnswers,
          if (answerCompleted != null) 'answersCompleted': answerCompleted,
        },
        isAuth: true,
      );
      log('answer-questions:::: $response');

      final success = response['success'] ?? false;
      if (!success) {
        return left(ServerFailure(response['message'] ?? 'فشل ارسال الاجابه'));
      }

      final data = UserModel.fromJson(response['data']);

      if (questionCategoryEnum == 'socialStatus') {
        final selectedStatus = normalizedAnswers.isNotEmpty
            ? normalizedAnswers.first['answer']?.toString()
            : null;
        final normalizedStatus = _normalizeSocialStatus(selectedStatus);

        final userToCache = (kCurrentUserData ?? data).copyWith(
          socialStatus: normalizedStatus,
        );
        kCurrentUserData = userToCache;
        await CachNetwork.setData(
          key: kuserData,
          value: jsonEncode(userToCache.toJson()),
        );
        log(">>>>>>>>>>>>>>>>>> status ${kCurrentUserData?.socialStatus}");
      } else if (questionCategoryEnum == 'hasChildren') {
        final selectedStatus = normalizedAnswers.isNotEmpty
            ? normalizedAnswers.first['answer']?.toString()
            : null;
        final hasChildren = selectedStatus == 'yes';

        final userToCache = (kCurrentUserData ?? data).copyWith(
          hasChildren: hasChildren,
        );
        kCurrentUserData = userToCache;
        await CachNetwork.setData(
          key: kuserData,
          value: jsonEncode(userToCache.toJson()),
        );
        log(">>>>>>>>>>>>>>>>>> hasChildren ${kCurrentUserData?.hasChildren}");
      }
      if (answerCompleted == true) {
        await CachNetwork.setData(
          key: kuserData,
          value: jsonEncode(data.toJson()),
        );
        kCurrentUserData = data;
      }
      return right(data);
    });
  }

  // ─────────────────────────────────────────────────────
  // Upload Personal Info (Images)
  // ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> uploadPersonalInfo({
    File? image,
    List<File>? images,
  }) {
    return _safeApiCall(() async {
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
      if (!success) {
        return left(ServerFailure(response['message'] ?? 'فشل ارسال البيانات'));
      }
      return right(null);
    });
  }

  // ─────────────────────────────────────────────────────
  // Verify Face Image
  // ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> verifyFaceImage({required XFile image}) {
    return _safeApiCall(() async {
      await apiService.post(
        endPoint: '/auth/verify-user-face',
        data: {'verifyImage': await uploadImageToApi(image)},
        isFromData: true,
      );
      return const Right(null);
    });
  }

  // ─────────────────────────────────────────────────────
  // Change Image Blur
  // ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> changeImageBlur() {
    return _safeApiCall(() async {
      final response = await apiService.patch(
        endPoint: '/auth/change-image-blur',
      );

      final success = response['success'] ?? false;
      if (!success) {
        return left(
          ServerFailure(response['message'] ?? 'فشل تغيير حالة التمويه'),
        );
      }
      return right(null);
    });
  }

  // ─────────────────────────────────────────────────────
  // Phone Number
  // ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> phoneNumber({
    required String phoneNumber,
    required String countryCode,
  }) {
    return _safeApiCall(() async {
      final response = await apiService.post(
        endPoint: '/user/update-phone-number',
        data: {'countryCode': countryCode, 'phone': phoneNumber},
      );

      final success = response['success'] ?? false;
      if (!success) {
        return left(
          ServerFailure(response['message'] ?? 'فشل ارسال رقم الهاتف'),
        );
      }
      return right(null);
    });
  }

  // ─────────────────────────────────────────────────────
  // Verify OTP
  // ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> verifyOtp({required String otp}) {
    return _safeApiCall(() async {
      final response = await apiService.post(
        endPoint: '/user/verfiy-phone',
        data: {'otp': otp},
      );

      final success = response['success'] ?? false;
      if (!success) {
        return left(
          ServerFailure(response['message'] ?? 'فشل التحقق من الكود'),
        );
      }
      return right(null);
    });
  }

  // ─────────────────────────────────────────────────────
  // Get Last Question Number
  // ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, LastQuestionNumber>> getLastQuestionNumber() {
    return _safeApiCall(() async {
      final response = await apiService.get(
        endPoint: '/user/last-question-number',
      );

      final success = response['success'] ?? false;
      if (!success) {
        return left(
          ServerFailure(
            response['message'] ?? 'فشل الحصول على رقم السؤال الأخير',
          ),
        );
      }

      try {
        final model = LastQuestionNumber.fromJson(response['data'] ?? {});
        return right(model);
      } catch (e) {
        return left(ServerFailure('فشل تجزئة بيانات الاستجابة: $e'));
      }
    });
  }

  // ─────────────────────────────────────────────────────
  // Add Preference Factors
  // ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> addPreferenceFactors({
    required String minAge,
    required String maxAge,
    required String country,
    required String nationality,
  }) {
    return _safeApiCall(() async {
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
      if (!success) {
        return left(
          ServerFailure(response['message'] ?? 'فشل إرسال تفضيلات الشريك'),
        );
      }
      return right(null);
    });
  }
}
