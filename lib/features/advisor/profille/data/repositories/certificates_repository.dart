import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../models/certificate_model.dart';

abstract class CertificatesRepository {
  Future<Either<Failure, CertificatesAndVideosResponse>>
  getCertificatesAndVideos();
}
