import 'dart:math';
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

        // ⭐ إبقاء القيمة كما هي (String)
        final yearsExp = data['yearsOfExperience'];
        String? yearsExpString = yearsExp?.toString();

        final profileData = {
          '_id': data['_id'] ?? '',
          'name': data['name'] ?? '',
          'username': data['username'] ?? '',
          'image': data['image'],
          'dateOfBirth': data['dateOfBirth'],
          'gender': data['gender'],
          'professionalSpecialization':
              data['professionalSpecialization'] ??
              data['ProfessionalSpecialization'], // ⭐ تحقق من الحقلين
          'jobGrade': data['jobGrade'] ?? data['JobGrade'], // ⭐ تحقق من الحقلين
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
      // ⭐ إنشاء Dio instance منفصلة
      final dio = Dio(
        BaseOptions(
          baseUrl: kbaseUrl,
          headers: {
            'Accept-Language': selectedLanguage ?? 'ar',
            'Accept': 'application/json',
            'Authorization':
                'Bearer ${CachNetwork.getStringData(key: 'token')}',
          },
          validateStatus: (status) => true, // ⭐ مهم: لا ترمي استثناءً
        ),
      );

      final formData = FormData();

      print('🔍 ====== REQUEST VALIDATION ======');

      // ⭐ 1. تحقق من username وتأكد أنه يبدأ بـ @
      String? username = request.username;
      if (username != null && username.isNotEmpty) {
        if (!username.startsWith('@')) {
          print('⚠️ Adding @ to username: $username → @$username');
          username = '@$username';
        }
        formData.fields.add(MapEntry('username', username));
        print('📤 username: $username');
      }

      // ⭐ 2. تحقق من name
      if (request.name != null && request.name!.isNotEmpty) {
        formData.fields.add(MapEntry('name', request.name!));
        print('📤 name: ${request.name!}');
      }

      // ⭐ 3. تحقق من professionalSpecialization
      if (request.professionalSpecialization != null &&
          request.professionalSpecialization!.isNotEmpty) {
        formData.fields.add(
          MapEntry(
            'ProfessionalSpecialization',
            request.professionalSpecialization!,
          ),
        );
        print(
          '📤 ProfessionalSpecialization: ${request.professionalSpecialization!}',
        );
      }

      // ⭐ 4. تحقق من jobGrade
      if (request.jobGrade != null && request.jobGrade!.isNotEmpty) {
        formData.fields.add(MapEntry('JobGrade', request.jobGrade!));
        print('📤 JobGrade: ${request.jobGrade!}');
      }

      // ⭐ 5. تحقق من yearsOfExperience - تأكد أنه رقم
      if (request.yearsOfExperience != null &&
          request.yearsOfExperience!.isNotEmpty) {
        String yearsExp = request.yearsOfExperience!;

        // ⭐ حاول تحويل النص العربي إلى رقم
        if (yearsExp.contains("سنتين")) {
          yearsExp = "2";
        } else if (yearsExp.contains("3 سنوات")) {
          yearsExp = "3";
        } else if (yearsExp.contains("5 سنوات")) {
          yearsExp = "5";
        } else if (yearsExp.contains("10 سنوات")) {
          yearsExp = "10";
        } else if (yearsExp.contains("أكثر من")) {
          yearsExp = "11";
        }

        // ⭐ استخراج أي رقم من النص
        final match = RegExp(r'(\d+)').firstMatch(yearsExp);
        if (match != null) {
          yearsExp = match.group(1)!;
        }

        formData.fields.add(MapEntry('yearsOfExperience', yearsExp));
        print('📤 yearsOfExperience (converted): $yearsExp');
      }

      // ⭐ 6. تحقق من aboutYou
      if (request.aboutYou != null && request.aboutYou!.isNotEmpty) {
        formData.fields.add(MapEntry('aboutYou', request.aboutYou!));
        print(
          '📤 aboutYou: ${request.aboutYou!.substring(0, min(request.aboutYou!.length, 50))}...',
        );
      }

      // ⭐ 7. معالجة الصورة
      if (imageFile != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
        print('📤 image: file added (${imageFile.path})');
      } else if (request.image == "") {
        formData.fields.add(MapEntry('image', ''));
        print('📤 image: (empty string for deletion)');
      }

      // ⭐ 8. معالجة الفيديو
      if (videoFile != null) {
        formData.files.add(
          MapEntry(
            'video',
            await MultipartFile.fromFile(
              videoFile.path,
              filename: 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
            ),
          ),
        );
        print('📤 video: file added (${videoFile.path})');
      } else if (request.video == "") {
        formData.fields.add(MapEntry('video', ''));
        print('📤 video: (empty string for deletion)');
      }

      print('🔍 ====== END VALIDATION ======');

      print('📤 Sending PATCH request to /advisor/editPersonalData');
      print(
        '📤 FormData has ${formData.fields.length} fields and ${formData.files.length} files',
      );

      final response = await dio.patch<Map<String, dynamic>>(
        '/advisor/editPersonalData',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');

      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData != null && responseData['success'] == true) {
          final updateResponse = UpdatePersonalDataResponse.fromJson(
            responseData,
          );
          return Right(updateResponse);
        } else {
          final errorMessage =
              responseData?['message']?.toString() ?? 'فشل تحديث البيانات';
          return Left(ServerFailure(errorMessage));
        }
      } else if (response.statusCode == 400) {
        // ⭐ معالجة خطأ التحقق بشكل مفصل
        String errorMessage = 'خطأ في التحقق من البيانات';

        if (responseData != null) {
          if (responseData['message'] != null) {
            errorMessage = responseData['message'].toString();
          } else if (responseData['errors'] != null) {
            final errors = responseData['errors'];
            if (errors is Map<String, dynamic>) {
              final errorList = errors.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join(', ');
              errorMessage = 'خطأ في الحقول: $errorList';
            }
          }
        }

        return Left(ServerFailure(errorMessage));
      } else {
        final errorMessage =
            responseData?['message']?.toString() ??
            'فشل تحديث البيانات (كود: ${response.statusCode})';
        return Left(ServerFailure(errorMessage));
      }
    } on DioException catch (e) {
      print('❌ DioException:');
      print('❌ Type: ${e.type}');
      print('❌ Message: ${e.message}');

      if (e.response != null) {
        print('❌ Status: ${e.response!.statusCode}');
        print('❌ Data: ${e.response!.data}');
      }

      String errorMessage = 'خطأ في الاتصال بالسيرفر';
      if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'].toString();
        }
      }

      return Left(ServerFailure(errorMessage));
    } catch (e, stack) {
      print('❌ Unexpected Error: $e');
      print('❌ Stack: $stack');
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }
}
