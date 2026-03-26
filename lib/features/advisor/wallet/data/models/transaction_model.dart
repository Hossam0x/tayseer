class TransactionModel {
  final String id;
  final String userId;
  final String type;
  final num amount;
  final String displayAmount;
  final String currency;
  final DateTime? createdAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.displayAmount,
    required this.currency,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      amount: json['amount'] ?? 0,
      displayAmount: json['displayAmount'] ?? '',
      currency: json['currency'] ?? 'USD',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  bool get isPositive => displayAmount.startsWith('+');
}

class PaginationModel {
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  const PaginationModel({
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }

  bool get hasNextPage => currentPage < totalPages;
}

class PaginatedTransactions {
  final List<TransactionModel> data;
  final PaginationModel pagination;

  const PaginatedTransactions({required this.data, required this.pagination});
}
