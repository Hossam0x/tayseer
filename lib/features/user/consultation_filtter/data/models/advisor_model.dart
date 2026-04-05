// lib/features/user/consultation/data/models/advisor_model.dart

class AdvisorPrice {
  final int duration;
  final double price;
  final String currency;

  const AdvisorPrice({
    required this.duration,
    required this.price,
    required this.currency,
  });

  factory AdvisorPrice.fromJson(Map<String, dynamic> json) {
    return AdvisorPrice(
      duration: json['duration'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'SAR',
    );
  }
}

class AdvisorFilterModel {
  final String id;
  final String name;
  final String subtitle;
  final String? imageUrl;
  final double rate;
  final int rateCount;
  final List<AdvisorPrice> prices;

  const AdvisorFilterModel({
    required this.id,
    required this.name,
    required this.subtitle,
    this.imageUrl,
    required this.rate,
    required this.rateCount,
    required this.prices,
  });

  // ✅ أرخص سعر موجود
  double get minPrice {
    if (prices.isEmpty) return 0;
    return prices.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  }

  factory AdvisorFilterModel.fromJson(Map<String, dynamic> json) {
    return AdvisorFilterModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['image'] as String?,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      rateCount: json['rateCount'] as int? ?? 0,
      prices: (json['prices'] as List<dynamic>?)
              ?.map((e) => AdvisorPrice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PaginatedAdvisorsModel {
  final List<AdvisorFilterModel> advisors;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  const PaginatedAdvisorsModel({
    required this.advisors,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
  });

  bool get hasNextPage => currentPage < totalPages;

  // ✅ بيتعامل مع الـ structure الصح
  // { "success": true, "data": { "advisors": [...], "pagination": {...} } }
  factory PaginatedAdvisorsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
    final rawList = data['advisors'] as List<dynamic>? ?? [];

    return PaginatedAdvisorsModel(
      advisors: rawList
          .map((e) => AdvisorFilterModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: pagination['currentPage'] as int? ?? 1,
      totalPages: pagination['totalPages'] as int? ?? 1,
      totalCount: pagination['totalCount'] as int? ?? 0,
    );
  }
}