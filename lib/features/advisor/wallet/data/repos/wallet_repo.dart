import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/features/advisor/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:tayseer/features/advisor/wallet/data/models/wallet_model.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';
import 'package:tayseer/features/advisor/wallet/data/models/balance_package_model.dart';
import 'package:tayseer/features/advisor/wallet/data/models/withdraw_model.dart';

class WalletRepo {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepo(this._remoteDataSource);

  Future<Either<Failure, WalletModel>> getWallet() async {
    try {
      final response = await _remoteDataSource.getWallet();
      if (response['success'] == true) {
        return Right(WalletModel.fromJson(response['data']));
      }
      return Left(
        ServerFailure(response['message'] ?? 'Error fetching wallet'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PaginatedTransactions>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getTransactions(
        page: page,
        limit: limit,
      );
      if (response['success'] == true) {
        final d = response['data'] as Map<String, dynamic>;
        return Right(
          PaginatedTransactions(
            data: (d['data'] as List)
                .map((x) => TransactionModel.fromJson(x))
                .toList(),
            pagination: PaginationModel.fromJson(d['pagination']),
          ),
        );
      }
      return Left(ServerFailure(response['message'] ?? 'Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PaginatedTransactions>> getEarnings({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getEarnings(
        page: page,
        limit: limit,
      );
      if (response['success'] == true) {
        final d = response['data'] as Map<String, dynamic>;
        return Right(
          PaginatedTransactions(
            data: (d['data'] as List)
                .map((x) => TransactionModel.fromJson(x))
                .toList(),
            pagination: PaginationModel.fromJson(d['pagination']),
          ),
        );
      }
      return Left(ServerFailure(response['message'] ?? 'Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<BalancePackageModel>>>
  getBalancePackages() async {
    try {
      final response = await _remoteDataSource.getBalancePackages();
      if (response['success'] == true) {
        final list = response['data'] as List;
        return Right(list.map((x) => BalancePackageModel.fromJson(x)).toList());
      }
      return Left(ServerFailure(response['message'] ?? 'Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Initiates an IAP purchase on the backend and returns the [pendingId]
  /// to be passed as [applicationUserName] to Apple/Google.
  Future<Either<Failure, String>> initiatePurchase({
    required String productId,
    required String platform,
  }) async {
    try {
      final response = await _remoteDataSource.initiatePurchase(
        productId: productId,
        platform: platform,
      );
      if (response['success'] == true) {
        final pendingId = response['data']['pendingId'] as String?;
        if (pendingId == null || pendingId.isEmpty) {
          return Left(ServerFailure('pendingId غير موجود في الاستجابة'));
        }
        return Right(pendingId);
      }
      return Left(ServerFailure(response['message'] ?? 'فشل بدء عملية الشراء'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Fetches the available withdraw methods + fee percentage from the API
  Future<
    Either<Failure, ({List<WithdrawMethod> methods, double feePercentage})>
  >
  getWithdrawMethods() async {
    try {
      final response = await _remoteDataSource.getWithdrawMethods();
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final methods = (data['methods'] as List)
            .map((m) => WithdrawMethod.fromApiValue(m as String))
            .toList();
        final feePercentage =
            (data['withdrawalFeePercentage'] as num?)?.toDouble() ?? 0.0;
        return Right((methods: methods, feePercentage: feePercentage));
      }
      return Left(ServerFailure(response['message'] ?? 'فشل جلب طرق السحب'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  /// Submits a withdrawal request — returns the created WithdrawModel
  Future<Either<Failure, WithdrawModel>> requestWithdraw({
    required WithdrawMethod method,
    required double amount,
    // Bank fields
    String? iban,
    String? accountHolderName,
    String? bankName,
    // Mobile wallet field
    String? phone,
  }) async {
    try {
      final response = await _remoteDataSource.requestWithdraw(
        method: method.toApiValue(),
        amount: amount,
        iban: iban,
        accountHolderName: accountHolderName,
        bankName: bankName,
        phone: phone,
      );
      if (response['success'] == true) {
        return Right(WithdrawModel.fromJson(response['data']));
      }
      return Left(ServerFailure(response['message'] ?? 'فشل طلب السحب'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }
}
