import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';

abstract class MarriageFilterRepo {
  Future<Either<Failure, void>> marriageFilter({
    required Map<String, dynamic> filters,
  });
}
