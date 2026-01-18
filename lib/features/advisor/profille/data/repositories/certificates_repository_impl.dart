import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import 'certificates_repository.dart';
import '../models/certificate_model.dart';

class CertificatesRepositoryImpl implements CertificatesRepository {
  final ApiService _apiService;

  CertificatesRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, CertificatesAndVideosResponse>>
  getCertificatesAndVideos() async {
    try {
      final response = await _apiService.get(
        endPoint: '/advisor/getAllCertificatesAndVideos',
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final certificatesResponse = CertificatesAndVideosResponse.fromJson(
          data,
        );
        return Right(certificatesResponse);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل جلب الشهادات والفيديوهات'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addCertificate({
    required String nameCertificate,
    required String fromWhere,
    required DateTime date,
    File? image,
  }) async {
    try {
      // ⭐ إنشاء Map بدلاً من FormData
      final Map<String, dynamic> data = {
        'nameCertificate': nameCertificate,
        'fromWhere': fromWhere,
        'date': date.toIso8601String(),
      };

      // ⭐ إضافة الصورة كـ MultipartFile إذا كانت موجودة
      if (image != null && image.existsSync()) {
        final String fileName = image.path.split('/').last;

        // ⭐ في Dio، نضيف الملفات بشكل مختلف عند استخدام FormData.fromMap()
        // لكن بما أن ApiService يستخدم FormData.fromMap(data)، نحتاج طريقة أخرى

        // ⭐ الحل: إنشاء FormData مباشرة وإضافة الحقول والملفات
        final FormData formData = FormData();

        // إضافة الحقول النصية
        formData.fields.addAll([
          MapEntry('nameCertificate', nameCertificate),
          MapEntry('fromWhere', fromWhere),
          MapEntry('date', date.toIso8601String()),
        ]);

        // إضافة الملف
        formData.files.add(
          MapEntry(
            'certificateImage',
            await MultipartFile.fromFile(image.path, filename: fileName),
          ),
        );

        // ⭐ استخدام dio مباشرة للطلب
        final dio = Dio();

        // الحصول على الهيدرات
        final Map<String, dynamic> headers = {
          'Authorization': 'Bearer ${CachNetwork.getStringData(key: 'token')}',
          'Accept': 'application/json',
        };

        final response = await dio.post(
          '$kbaseUrl/advisor/addCertificate',
          data: formData,
          options: Options(headers: headers),
        );

        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          return Right(responseData);
        } else {
          return Left(
            ServerFailure(responseData['message'] ?? 'فشل إضافة الشهادة'),
          );
        }
      } else {
        // ⭐ إذا لم تكن هناك صورة، استخدم ApiService العادي
        final response = await _apiService.post(
          endPoint: '/advisor/addCertificate',
          data: data,
          isFromData: true,
        );

        if (response['success'] == true) {
          return Right(response);
        } else {
          return Left(
            ServerFailure(response['message'] ?? 'فشل إضافة الشهادة'),
          );
        }
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateCertificate({
    required String certificateId,
    required String nameCertificate,
    required String fromWhere,
    required DateTime date,
    File? image,
  }) async {
    try {
      // ⭐ إنشاء Map بدلاً من FormData
      final Map<String, dynamic> data = {
        'nameCertificate': nameCertificate,
        'fromWhere': fromWhere,
        'date': date.toIso8601String(),
      };

      // ⭐ إذا كانت هناك صورة
      if (image != null && image.existsSync()) {
        final String fileName = image.path.split('/').last;

        // ⭐ إنشاء FormData مباشرة
        final FormData formData = FormData();

        // إضافة الحقول النصية
        formData.fields.addAll([
          MapEntry('nameCertificate', nameCertificate),
          MapEntry('fromWhere', fromWhere),
          MapEntry('date', date.toIso8601String()),
        ]);

        // إضافة الملف
        formData.files.add(
          MapEntry(
            'certificateImage',
            await MultipartFile.fromFile(image.path, filename: fileName),
          ),
        );

        // ⭐ استخدام dio مباشرة
        final dio = Dio();

        // الحصول على الهيدرات
        final Map<String, dynamic> headers = {
          'Authorization': 'Bearer ${CachNetwork.getStringData(key: 'token')}',
          'Accept': 'application/json',
        };

        final response = await dio.patch(
          '$kbaseUrl/advisor/updateCertificate/$certificateId',
          data: formData,
          options: Options(headers: headers),
        );

        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          return Right(responseData);
        } else {
          return Left(
            ServerFailure(responseData['message'] ?? 'فشل تحديث الشهادة'),
          );
        }
      } else {
        // ⭐ إذا لم تكن هناك صورة، استخدم ApiService العادي
        final response = await _apiService.patch(
          endPoint: '/advisor/updateCertificate/$certificateId',
          data: data,
          isFromData: true,
        );

        if (response['success'] == true) {
          return Right(response);
        } else {
          return Left(
            ServerFailure(response['message'] ?? 'فشل تحديث الشهادة'),
          );
        }
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
