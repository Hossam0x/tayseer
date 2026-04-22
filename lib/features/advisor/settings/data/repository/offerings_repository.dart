import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/settings/data/models/offerings_model.dart';
import 'package:tayseer/my_import.dart';

abstract class OfferingsRepository {
  Future<Either<Failure, OfferingsResponse>> getOfferings();
  Future<Either<Failure, OfferingsResponse>> setOfferings({
    required Map<String, dynamic> body,
  });
}

class OfferingsRepositoryImpl implements OfferingsRepository {
  final ApiService _apiService;

  OfferingsRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, OfferingsResponse>> getOfferings() async {
    try {
      final response = await _apiService.get(endPoint: '/advisor/my-offerings');

      if (response['success'] == true) {
        return Right(OfferingsResponse.fromJson(response));
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ?? 'failed_to_fetch_offerings',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OfferingsResponse>> setOfferings({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: '/advisor/offerings',
        data: body,
      );

      if (response['success'] == true) {
        return Right(OfferingsResponse.fromJson(response));
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ?? 'failed_to_set_offerings',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
