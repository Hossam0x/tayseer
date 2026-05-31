import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/membership/data/models/my_subscription_model.dart';
import 'package:tayseer/features/advisor/membership/data/models/restore_purchase_result.dart';
import 'package:tayseer/features/user/my_space/data/model/paymob/payment_intention_model.dart';
import 'package:tayseer/my_import.dart';

abstract class MembershipRepository {
  Future<Either<Failure, MySubscriptionModel>> getMySubscription();
  Future<Either<Failure, void>> cancelMySubscription();
  Future<Either<Failure, RestorePurchaseResult>> restorePurchase(
    String receipt, {
    String? originalTransactionId,
  });
  Future<Either<Failure, void>> transferSubscription(String purchaseId);

  /// Initiates an IAP purchase on the backend and returns the [pendingId]
  /// to be passed as [applicationUserName] to Apple/Google.
  Future<Either<Failure, String>> initiatePurchase({
    required String productId,
    required String platform,
  });

  /// Initiates a Google/Paymob subscription payment.
  /// Returns [PaymentIntentionData] with clientSecret and publicKey for the SDK.
  Future<Either<Failure, PaymentIntentionData>>
  initiateGoogleSubscriptionPayment({
    required String subscriptionId,
    required String subscriptionType,
    required bool saveCard,
  });

  /// Cancels Android auto-renewal via Paymob backend.
  Future<Either<Failure, void>> cancelAndroidAutoRenewal();
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
      log('[AdvisorRepo] ════════════════════════════════════════');
      log('[AdvisorRepo] 📤 SENDING cancel to backend');
      log('[AdvisorRepo]   endpoint: ${ApiEndPoint.cancelAdvisorSubscription}');
      log(
        '[AdvisorRepo]   body: {} (empty — backend uses token to identify user)',
      );
      log('[AdvisorRepo] ════════════════════════════════════════');

      final response = await _apiService.post(
        endPoint: ApiEndPoint.cancelAdvisorSubscription,
        data: {},
      );

      log('[AdvisorRepo] 📩 RECEIVED from backend (cancel):');
      log('[AdvisorRepo]   success : ${response['success']}');
      log('[AdvisorRepo]   message : ${response['message']}');
      log('[AdvisorRepo]   data    : ${response['data']}');

      if (response['success'] == true) {
        return const Right(null);
      }
      return Left(
        ServerFailure(response['message']?.toString() ?? 'فشل إلغاء الاشتراك'),
      );
    } on DioException catch (e) {
      log('[AdvisorRepo] ❌ DioException on cancel: ${e.message}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      log('[AdvisorRepo] ❌ Exception on cancel: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RestorePurchaseResult>> restorePurchase(
    String receipt, {
    String? originalTransactionId,
  }) async {
    try {
      final body = <String, dynamic>{
        'receipts': [receipt],
      };
      if (originalTransactionId != null && originalTransactionId.isNotEmpty) {
        body['originalTransactionId'] = originalTransactionId;
      }

      log('[MembershipRepo] restorePurchase body keys: ${body.keys.toList()}');
      if (originalTransactionId != null) {
        log('[MembershipRepo] originalTransactionId: $originalTransactionId');
      }

      final response = await _apiService.post(
        endPoint: ApiEndPoint.iapRestorePurchase,
        data: body,
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

  @override
  Future<Either<Failure, String>> initiatePurchase({
    required String productId,
    required String platform,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.initiatePurchase,
        data: {'productId': productId, 'platform': platform},
      );
      if (response['success'] == true) {
        final pendingId = response['data']['pendingId'] as String?;
        if (pendingId == null || pendingId.isEmpty) {
          return Left(ServerFailure('pendingId غير موجود في الاستجابة'));
        }
        return Right(pendingId);
      }
      return Left(
        ServerFailure(
          response['message']?.toString() ?? 'فشل بدء عملية الشراء',
        ),
      );
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentIntentionData>>
  initiateGoogleSubscriptionPayment({
    required String subscriptionId,
    required String subscriptionType,
    required bool saveCard,
  }) async {
    try {
      log('[MembershipRepo] initiateGoogleSubscriptionPayment');
      log('[MembershipRepo]   subscriptionId   : $subscriptionId');
      log('[MembershipRepo]   subscriptionType : $subscriptionType');
      log('[MembershipRepo]   saveCard         : $saveCard');

      final response = await _apiService.post(
        endPoint: ApiEndPoint.initiateGoogleSubscriptionPayment,
        data: {
          'subscriptionId': subscriptionId,
          'subscriptionType': subscriptionType,
          'saveCard': saveCard,
        },
      );

      if (response['success'] == true) {
        return Right(
          PaymentIntentionData.fromJson(
            response['data'] as Map<String, dynamic>,
          ),
        );
      }
      // ✅ لو الـ backend رجّع phoneRequired: true نرجع كود خاص
      final data = response['data'];
      if (data != null && data['phoneRequired'] == true) {
        return Left(ServerFailure('profileIncomplete'));
      }
      return Left(
        ServerFailure(response['message']?.toString() ?? 'فشل بدء عملية الدفع'),
      );
    } on DioException catch (e) {
      // ✅ لو الـ backend رجّع 400 مع phoneRequired: true
      final data = e.response?.data;
      if (data != null &&
          data['data'] != null &&
          data['data']['phoneRequired'] == true) {
        return Left(ServerFailure('profileIncomplete'));
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAndroidAutoRenewal() async {
    try {
      log('[MembershipRepo] cancelAndroidAutoRenewal');
      final response = await _apiService.post(
        endPoint: ApiEndPoint.cancelAndroidAutoRenewal,
        data: {},
      );
      if (response['success'] == true) {
        return const Right(null);
      }
      return Left(
        ServerFailure(
          response['message']?.toString() ?? 'فشل إلغاء التجديد التلقائي',
        ),
      );
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
