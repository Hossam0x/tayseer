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
      final advisorId = await _getAdvisorId();
      
      final response = await _apiService.get(
        endPoint: '/advisor/getAllCertificatesAndVideos/$advisorId',
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final certificatesResponse = CertificatesAndVideosResponse.fromJson(data);
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

  Future<String> _getAdvisorId() async {
    // TODO: استبدل هذا بآلية حقيقية لجلب الـ advisorId
    return '6947e98df9f8bce3bf355fc0';
  }
}