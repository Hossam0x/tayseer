import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../models/certificate_model.dart';

abstract class CertificatesRepository {
  Future<Either<Failure, CertificatesAndVideosResponse>>
  getCertificatesAndVideos();

  Future<Either<Failure, Map<String, dynamic>>> addCertificate({
    required String nameCertificate,
    required String fromWhere,
    required DateTime date,
    File? image,
  });

  Future<Either<Failure, Map<String, dynamic>>> updateCertificate({
    required String certificateId,
    required String nameCertificate,
    required String fromWhere,
    required DateTime date,
    File? image,
  });
}
