import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/membership/data/models/my_subscription_model.dart';
import 'package:tayseer/my_import.dart';

abstract class MembershipRepository {
  Future<Either<Failure, MySubscriptionModel>> getMySubscription();
  Future<Either<Failure, void>> cancelMySubscription();
}

class MembershipRepositoryImpl implements MembershipRepository {
  final ApiService _apiService;

  MembershipRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, MySubscriptionModel>> getMySubscription() async {
    try {
      final response = await _apiService.get(
        endPoint: ApiEndPoint.myAdvisorSubscription,
      );
      if (response['success'] == true) {
        final model = MySubscriptionModel.fromJson(
          response['data'] as Map<String, dynamic>,
        );
        return Right(model);
      }
      return Left(
        ServerFailure(
          response['message']?.toString() ?? 'فشل استرجاع بيانات الاشتراك',
        ),
      );
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelMySubscription() async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.cancelAdvisorSubscription,
        data: {},
      );
      if (response['success'] == true) {
        return const Right(null);
      }
      return Left(
        ServerFailure(response['message']?.toString() ?? 'فشل إلغاء الاشتراك'),
      );
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
