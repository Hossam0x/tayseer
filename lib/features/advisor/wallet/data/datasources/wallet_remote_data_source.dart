import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';

abstract class WalletRemoteDataSource {
  Future<Map<String, dynamic>> getWallet();
  Future<Map<String, dynamic>> getTransactions({required int page, int? limit});
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
    required int page,
    int? limit,
  }) async {
    return await _apiService.get(
      endPoint: ApiEndPoint.walletTransactions,
      query: {'page': page, if (limit != null) 'limit': limit},
    );
  }
}
