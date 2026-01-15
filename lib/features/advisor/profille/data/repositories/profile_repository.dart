import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../models/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> getAdvisorProfile();
}
