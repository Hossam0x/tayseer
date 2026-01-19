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

        // ⭐ تعديل هنا: إبقاء القيمة كما هي (String)
        final yearsExp = data['yearsOfExperience'];
        String? yearsExpString = yearsExp?.toString(); // ⭐ تحويل إلى String فقط

        final profileData = {
          '_id': data['_id'] ?? '',
          'name': data['name'] ?? '',
          'username': data['username'] ?? '',
          'image': data['image'],
          'dateOfBirth': data['dateOfBirth'],
          'gender': data['gender'],
          'professionalSpecialization': data['professionalSpecialization'],
          'jobGrade': data['jobGrade'],
          'yearsOfExperience': yearsExpString, // ⭐ String
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
      final formData = FormData();

      // إضافة الحقول النصية مع مراعاة الـ mapping العكسي
      if (request.name != null && request.name!.isNotEmpty) {
        formData.fields.add(MapEntry('name', request.name!));
      }

      if (request.username != null && request.username!.isNotEmpty) {
        formData.fields.add(MapEntry('username', request.username!));
      }

      // ⭐ تحويل professionalSpecialization إلى القيمة المتوقعة من الباكند
      if (request.professionalSpecialization != null &&
          request.professionalSpecialization!.isNotEmpty) {
        // هنا قد تحتاج إلى mapping عكسي إذا كان الباكند يتوقع قيماً محددة
        formData.fields.add(
          MapEntry(
            'ProfessionalSpecialization',
            request.professionalSpecialization!,
          ),
        );
      }

      if (request.jobGrade != null && request.jobGrade!.isNotEmpty) {
        formData.fields.add(MapEntry('JobGrade', request.jobGrade!));
      }

      if (request.yearsOfExperience != null &&
          request.yearsOfExperience!.isNotEmpty) {
        formData.fields.add(
          MapEntry('yearsOfExperience', request.yearsOfExperience!),
        );
      }

      if (request.aboutYou != null && request.aboutYou!.isNotEmpty) {
        formData.fields.add(MapEntry('aboutYou', request.aboutYou!));
      }

      // ⭐ معالجة الصورة
      if (imageFile != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: 'profile_image.jpg',
            ),
          ),
        );
      } else if (request.image == "") {
        // ⭐ إذا كانت الصورة محذوفة، أرسل قيمة فارغة
        formData.fields.add(MapEntry('image', ''));
      }

      // ⭐ معالجة الفيديو
      if (videoFile != null) {
        formData.files.add(
          MapEntry(
            'video',
            await MultipartFile.fromFile(
              videoFile.path,
              filename: 'intro_video.mp4',
            ),
          ),
        );
      } else if (request.video == "") {
        // ⭐ إذا كان الفيديو محذوفاً، أرسل قيمة فارغة
        formData.fields.add(MapEntry('video', ''));
      }

      print('📤 Sending PATCH request to /advisor/editPersonalData');
      print('📤 Has image to delete: ${request.image == ""}');
      print('📤 Has video to delete: ${request.video == ""}');

      final response = await _apiService.patch(
        endPoint: '/advisor/editPersonalData',
        data: formData,
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
