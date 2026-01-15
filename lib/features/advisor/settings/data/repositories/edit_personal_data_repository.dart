import 'package:dartz/dartz.dart';
import 'package:http_parser/http_parser.dart';
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
  Future<String?> uploadFile(File file, String fieldName);
}

class EditPersonalDataRepositoryImpl implements EditPersonalDataRepository {
  final ApiService _apiService;
  final Dio _dio;

  EditPersonalDataRepositoryImpl(this._apiService, this._dio);

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
      // إنشاء FormData
      final formData = FormData.fromMap({
        ...request.toFormData(),
        // إضافة flag لحذف الفيديو إذا تم الطلب
        if (removeVideo == true) 'removeVideo': 'true',
      });

      // إضافة ملف الصورة إذا كان موجوداً
      if (imageFile != null) {
        final fileName = imageFile.path.split('/').last;
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      // إضافة ملف الفيديو إذا كان موجوداً
      if (videoFile != null) {
        final fileName = videoFile.path.split('/').last;
        formData.files.add(
          MapEntry(
            'video',
            await MultipartFile.fromFile(
              videoFile.path,
              filename: fileName,
              contentType: MediaType('video', 'mp4'),
            ),
          ),
        );
      }

      print('📤 Sending PATCH request to /advisor/editPersonalData');
      print('📤 FormData keys: ${formData.fields.map((e) => e.key)}');
      print('📤 Files count: ${formData.files.length}');
      print('📤 Remove video: $removeVideo');

      // استخدام baseUrl الصحيح من الـ Dio
      final baseUrl = _dio.options.baseUrl;
      if (baseUrl.isEmpty) {
        return Left(ServerFailure('Base URL not configured'));
      }

      final fullUrl = '$baseUrl/advisor/editPersonalData';
      print('📤 Full URL: $fullUrl');

      // إرسال الطلب
      final response = await _apiService.patch(
        endPoint: '/advisor/editPersonalData',
        isFromData: true,
        data: formData,
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
      print('❌ Dio Error Stack: ${e.stackTrace}');

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

  @override
  Future<String?> uploadFile(File file, String fieldName) async {
    try {
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        'upload',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] == true) {
        return responseData['data']['url'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error uploading file: $e');
      return null;
    }
  }
}
