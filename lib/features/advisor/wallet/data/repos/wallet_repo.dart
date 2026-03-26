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
}
