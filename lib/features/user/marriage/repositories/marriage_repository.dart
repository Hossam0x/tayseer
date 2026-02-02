import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';
import 'package:tayseer/my_import.dart';

abstract class MarriageRepository {
  Future<Either<Failure, UsersMarriageResponse>> getMarriageProfile();
}
