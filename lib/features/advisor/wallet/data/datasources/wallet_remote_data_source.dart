import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';

abstract class WalletRemoteDataSource {
  Future<Map<String, dynamic>> getWallet();
  Future<Map<String, dynamic>> getTransactions({int page = 1, int limit = 20});
  Future<Map<String, dynamic>> getEarnings({int page = 1, int limit = 20});
  Future<Map<String, dynamic>> getBalancePackages();
  Future<Map<String, dynamic>> initiatePurchase({
    required String productId,
    required String platform,
  });
  Future<Map<String, dynamic>> getWithdrawMethods();
  Future<Map<String, dynamic>> requestWithdraw({
    required String method,
    required double amount,
    // Bank fields
    String? iban,
    String? accountHolderName,
    String? bankName,
    // Mobile wallet field
    String? phone,
  });
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

  @override
  Future<Map<String, dynamic>> getBalancePackages() async {
    return await _apiService.get(endPoint: ApiEndPoint.balancePackages);
  }

  @override
  Future<Map<String, dynamic>> initiatePurchase({
    required String productId,
    required String platform,
  }) async {
    return await _apiService.post(
      endPoint: ApiEndPoint.initiatePurchase,
      data: {'productId': productId, 'platform': platform},
    );
  }

  @override
  Future<Map<String, dynamic>> getWithdrawMethods() async {
    return await _apiService.get(endPoint: ApiEndPoint.withdrawMethods);
  }

  @override
  Future<Map<String, dynamic>> requestWithdraw({
    required String method,
    required double amount,
    String? iban,
    String? accountHolderName,
    String? bankName,
    String? phone,
  }) async {
    final data = <String, dynamic>{
      'amount': amount,
      'withdrawalMethod': method,
    };
    if (iban != null) data['IBAN'] = iban;
    if (accountHolderName != null)
      data['accountHolderName'] = accountHolderName;
    if (bankName != null) data['bankName'] = bankName;
    if (phone != null) data['phone'] = phone;

    return await _apiService.post(endPoint: ApiEndPoint.withdraw, data: data);
  }
}
