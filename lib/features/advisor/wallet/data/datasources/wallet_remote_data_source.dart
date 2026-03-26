import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';

abstract class WalletRemoteDataSource {
  Future<Map<String, dynamic>> getWallet();
  Future<Map<String, dynamic>> getTransactions({int page = 1, int limit = 20});
  Future<Map<String, dynamic>> getEarnings({int page = 1, int limit = 20});
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiService _apiService;

  WalletRemoteDataSourceImpl(this._apiService);

  @override
  Future<Map<String, dynamic>> getWallet() async {
    return await _apiService.get(endPoint: ApiEndPoint.wallet);
  }

  @override
  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    return await _apiService.get(
      endPoint: ApiEndPoint.walletTransactions,
      query: {'page': page, 'limit': limit},
    );
  }

  @override
  Future<Map<String, dynamic>> getEarnings({
    int page = 1,
    int limit = 20,
  }) async {
    return await _apiService.get(
      endPoint: ApiEndPoint.walletEarnings,
      query: {'page': page, 'limit': limit},
    );
  }
}
