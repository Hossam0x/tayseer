import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';

class WalletModel {
  final num? balance;
  final num? availableBalance;
  final String? currency;
  final List<TransactionModel>? transactions;
  final WalletPagination? pagination;

  WalletModel({
    this.balance,
    this.availableBalance,
    this.currency,
    this.transactions,
    this.pagination,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: json['balance'],
      availableBalance: json['availableBalance'],
      currency: json['currency'],
      transactions: json['transactions'] != null
          ? List<TransactionModel>.from(
              json['transactions'].map((x) => TransactionModel.fromJson(x)),
            )
          : null,
      pagination: json['pagination'] != null
          ? WalletPagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class WalletPagination {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;

  WalletPagination({this.page, this.limit, this.total, this.totalPages});

  factory WalletPagination.fromJson(Map<String, dynamic> json) {
    return WalletPagination(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
    );
  }
}
