class PaginationModel {
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int limit;

  const PaginationModel({
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
    );
  }

  bool get hasMore => currentPage < totalPages;
}
