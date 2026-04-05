import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../../../../shared/profile/data/repositories/certificates_repository.dart';
import '../../../../shared/profile/data/models/certificate_model.dart';

class CertificatesRepositoryImpl implements CertificatesRepository {
  final ApiService _apiService;

  CertificatesRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, CertificatesAndVideosResponse>>
  getCertificatesAndVideos({
    String? advisorId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String endpoint = '/advisor/getAllCertificatesAndVideos';
      Map<String, dynamic> query = {'page': page, 'limit': limit};

      if (advisorId != null) {
        endpoint = '/advisor/getAllCertificatesAndVideos/$advisorId';
      }

      final response = await _apiService.get(endPoint: endpoint, query: query);

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final pagination = Map<String, dynamic>.from(data['pagination'] ?? {});

        final certificatesResponse = CertificatesAndVideosResponse.fromJson(
          data,
          pagination: pagination,
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
    File? image, // Keep as nullable File
  }) async {
    try {
      final Map<String, dynamic> data = {
        'nameCertificate': nameCertificate,
        'fromWhere': fromWhere,
        'date': date.toIso8601String(),
      };

      if (image != null && image.existsSync()) {
        final String fileName = image.path.split('/').last;
        final FormData formData = FormData();

        formData.fields.addAll([
          MapEntry('nameCertificate', nameCertificate),
          MapEntry('fromWhere', fromWhere),
          MapEntry('date', date.toIso8601String()),
        ]);

        formData.files.add(
          MapEntry(
            'image', // Changed from 'certificateImage' to 'image' based on typical multer conventions and error
            await MultipartFile.fromFile(image.path, filename: fileName),
          ),
        );

        final dio = Dio();
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
        final response = await _apiService.post(
          endPoint: '/advisor/addCertificate',
          data: data,
          isFromData: false,
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
    bool? removeImage,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'nameCertificate': nameCertificate,
        'fromWhere': fromWhere,
        'date': date.toIso8601String(),
      };

      if (removeImage == true) {
        data['image'] = ""; // أو حسب ما يتوقعه الباك لحذف الصورة
      }

      if (image != null && image.existsSync()) {
        final String fileName = image.path.split('/').last;
        final FormData formData = FormData();

        formData.fields.addAll([
          MapEntry('nameCertificate', nameCertificate),
          MapEntry('fromWhere', fromWhere),
          MapEntry('date', date.toIso8601String()),
        ]);

        if (removeImage == true) {
          formData.fields.add(const MapEntry('image', ""));
        }

        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(image.path, filename: fileName),
          ),
        );

        final dio = Dio();
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
        final response = await _apiService.patch(
          endPoint: '/advisor/updateCertificate/$certificateId',
          data: data,
          isFromData: false,
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
