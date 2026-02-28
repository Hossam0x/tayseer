import 'package:dartz/dartz.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/features/advisor/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:tayseer/features/advisor/wallet/data/models/wallet_model.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';

class WalletRepo {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepo(this._remoteDataSource);

  Future<Either<Failure, WalletModel>> getWallet() async {
    try {
      final response = await _remoteDataSource.getWallet();
      if (response['success'] == true) {
        return Right(WalletModel.fromJson(response['data']));
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'Error fetching wallet'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<TransactionModel>>> getTransactions({
    required int page,
    int? limit,
  }) async {
    try {
      final response = await _remoteDataSource.getTransactions(
        page: page,
        limit: limit,
      );
      if (response['success'] == true) {
        final List<TransactionModel> transactions = List<TransactionModel>.from(
          response['data']['transactions'].map(
            (x) => TransactionModel.fromJson(x),
          ),
        );
        return Right(transactions);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'Error fetching transactions'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
