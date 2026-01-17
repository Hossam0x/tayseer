import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../models/edit_personal_data_models.dart';

abstract class EditPersonalDataRepository {
  Future<Either<Failure, AdvisorProfileModel>> getAdvisorProfile();
  Future<Either<Failure, UpdatePersonalDataResponse>> updatePersonalData({
    required UpdatePersonalDataRequest request,
    File? imageFile,
    File? videoFile,
    bool? removeVideo,
  });
}

class EditPersonalDataRepositoryImpl implements EditPersonalDataRepository {
  final ApiService _apiService;

  EditPersonalDataRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, AdvisorProfileModel>> getAdvisorProfile() async {
    try {
      final response = await _apiService.get(endPoint: ApiEndPoint.profileData);

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;

        final yearsExp = data['yearsOfExperience'];
        String? yearsExpString;

        if (yearsExp != null) {
          if (yearsExp is num) {
            final intValue = yearsExp.toInt();
            if (intValue == 2) {
              yearsExpString = "سنتين";
            } else if (intValue == 3) {
              yearsExpString = "3 سنوات";
            } else if (intValue == 5) {
              yearsExpString = "5 سنوات";
            } else if (intValue == 10) {
              yearsExpString = "10 سنوات";
            } else if (intValue > 10) {
              yearsExpString = "أكثر من 10 سنوات";
            } else {
              yearsExpString = yearsExp.toString();
            }
          } else {
            yearsExpString = yearsExp.toString();
          }
        }

        final profileData = {
          '_id': data['_id'] ?? '',
          'name': data['name'] ?? '',
          'username': data['username'] ?? '',
          'image': data['image'],
          'dateOfBirth': data['dateOfBirth'],
          'gender': data['gender'],
          'professionalSpecialization': data['professionalSpecialization'],
          'jobGrade': data['jobGrade'],
          'yearsOfExperience': yearsExpString,
          'aboutYou': data['aboutYou'],
          'videoLink': data['videoLink'],
          'isVerified': data['isVerified'] ?? false,
          'followers': data['followers'] ?? 0,
          'following': data['following'] ?? 0,
          'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
          'postsCount': data['postsCount'] ?? 0,
        };

        final profile = AdvisorProfileModel.fromJson(profileData);
        return Right(profile);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب البروفايل'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UpdatePersonalDataResponse>> updatePersonalData({
    required UpdatePersonalDataRequest request,
    File? imageFile,
    File? videoFile,
    bool? removeVideo,
  }) async {
    try {
      // ⭐ إنشاء FormData وإضافة البيانات النصية
      final Map<String, dynamic> formDataMap = {};

      // إضافة الحقول النصية
      if (request.name != null && request.name!.isNotEmpty) {
        formDataMap['name'] = request.name!;
      }

      if (request.professionalSpecialization != null &&
          request.professionalSpecialization!.isNotEmpty) {
        formDataMap['ProfessionalSpecialization'] =
            request.professionalSpecialization!;
      }

      if (request.jobGrade != null && request.jobGrade!.isNotEmpty) {
        formDataMap['JobGrade'] = request.jobGrade!;
      }

      if (request.yearsOfExperience != null &&
          request.yearsOfExperience!.isNotEmpty) {
        formDataMap['yearsOfExperience'] = request.yearsOfExperience!;
      }

      if (request.aboutYou != null && request.aboutYou!.isNotEmpty) {
        formDataMap['aboutYou'] = request.aboutYou!;
      }

      print('📤 Sending PATCH request to /advisor/editPersonalData');
      print('📤 Text fields: $formDataMap');
      print('📤 Has image file: ${imageFile != null}');
      print('📤 Has video file: ${videoFile != null}');
      print('📤 Remove video: $removeVideo');

      // ⭐ إرسال الطلب باستخدام ApiService مع isFromData: true
      final response = await _apiService.patch(
        endPoint: '/advisor/editPersonalData',
        data: formDataMap,
        isFromData: true,
        headers: {'Content-Type': 'multipart/form-data'},
      );

      final responseData = response;
      print('📥 Response: $responseData');

      if (responseData['success'] == true) {
        final updateResponse = UpdatePersonalDataResponse.fromJson(
          responseData,
        );
        return Right(updateResponse);
      } else {
        return Left(
          ServerFailure(
            responseData['message']?.toString() ?? 'فشل تحديث البيانات',
          ),
        );
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      print('❌ Dio Error Type: ${e.type}');
      print('❌ Dio Error Response: ${e.response?.data}');

      String errorMessage = 'خطأ في الاتصال بالسيرفر';
      if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'].toString();
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      return Left(ServerFailure(errorMessage));
    } catch (e, stack) {
      print('❌ Error: $e');
      print('❌ Stack: $stack');
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }
}
