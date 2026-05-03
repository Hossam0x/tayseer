import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/membership/data/models/my_subscription_model.dart';
import 'package:tayseer/features/advisor/membership/data/models/restore_purchase_result.dart';
import 'package:tayseer/my_import.dart';

abstract class MembershipRepository {
  Future<Either<Failure, MySubscriptionModel>> getMySubscription();
  Future<Either<Failure, void>> cancelMySubscription();
  Future<Either<Failure, RestorePurchaseResult>> restorePurchase(
    String receipt,
  );
  Future<Either<Failure, void>> transferSubscription(String purchaseId);
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

  @override
  Future<Either<Failure, RestorePurchaseResult>> restorePurchase(
    String receipt,
  ) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.iapRestorePurchase,
        data: {
          'receipts': [receipt],
        },
      );
      if (response['success'] == true) {
        // data is a List — take the first element
        final rawData = response['data'];
        final Map<String, dynamic> data;
        if (rawData is List && rawData.isNotEmpty) {
          data = Map<String, dynamic>.from(rawData.first as Map);
        } else if (rawData is Map<String, dynamic>) {
          data = rawData;
        } else {
          data = {};
        }
        return Right(RestorePurchaseResult.fromJson(data));
      }
      return Left(
        ServerFailure(
          response['message']?.toString() ?? 'فشل استعادة الاشتراك',
        ),
      );
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> transferSubscription(String purchaseId) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.iapTransferSubscription,
        data: {'purchaseId': purchaseId},
      );
      if (response['success'] == true) {
        return const Right(null);
      }
      return Left(
        ServerFailure(response['message']?.toString() ?? 'فشل نقل الاشتراك'),
      );
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
