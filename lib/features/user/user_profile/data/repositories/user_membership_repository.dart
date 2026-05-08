import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/membership/data/models/my_subscription_model.dart';
import 'package:tayseer/my_import.dart';

abstract class UserMembershipRepository {
  Future<Either<Failure, MySubscriptionModel>> getMySubscription();
  Future<Either<Failure, void>> cancelMySubscription();
}

class UserMembershipRepositoryImpl implements UserMembershipRepository {
  final ApiService _apiService;

  UserMembershipRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, MySubscriptionModel>> getMySubscription() async {
    try {
      final response = await _apiService.get(
        endPoint: ApiEndPoint.myUserSubscription,
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
      log('[UserRepo] ════════════════════════════════════════');
      log('[UserRepo] 📤 SENDING cancel to backend');
      log('[UserRepo]   endpoint: ${ApiEndPoint.cancelUserSubscription}');
      log(
        '[UserRepo]   body: {} (empty — backend uses token to identify user)',
      );
      log('[UserRepo] ════════════════════════════════════════');

      final response = await _apiService.post(
        endPoint: ApiEndPoint.cancelUserSubscription,
        data: {},
      );

      log('[UserRepo] 📩 RECEIVED from backend (cancel):');
      log('[UserRepo]   success : ${response['success']}');
      log('[UserRepo]   message : ${response['message']}');
      log('[UserRepo]   data    : ${response['data']}');

      if (response['success'] == true) {
        return const Right(null);
      }
      return Left(
        ServerFailure(response['message']?.toString() ?? 'فشل إلغاء الاشتراك'),
      );
    } on DioException catch (e) {
      log('[UserRepo] ❌ DioException on cancel: ${e.message}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      log('[UserRepo] ❌ Exception on cancel: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
