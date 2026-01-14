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
        final profile = AdvisorProfileModel.fromJson(data);
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
  }) async {
    try {
      // إنشاء FormData
      final formData = FormData.fromMap(request.toFormData());

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

      // إرسال الطلب
      final response = await _dio.patch(
        '${_dio.options.baseUrl}/advisor/editPersonalData',
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
      if (e.response != null) {
        print('❌ Response data: ${e.response!.data}');
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      print('❌ Error: $e');
      return Left(ServerFailure(e.toString()));
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
        '${_dio.options.baseUrl}/upload',
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
