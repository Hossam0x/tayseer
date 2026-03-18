// lib/features/filter/data/models/advisor_filter_request_model.dart

class AdvisorFilterRequestModel {
  final double? priceMin;
  final double? priceMax;
  final String? language;
  final int? yearsOfExperience;
  final double? rating;
  final int? dayOfWeek;
  final int page;

  const AdvisorFilterRequestModel({
    this.priceMin,
    this.priceMax,
    this.language,
    this.yearsOfExperience,
    this.rating,
    this.dayOfWeek,
    this.page = 1,
  });

  // ✅ بيتحول لـ query params زي الـ API
  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {
      'page': page.toString(),
    };

    if (priceMin != null) params['priceMin'] = priceMin!.toInt().toString();
    if (priceMax != null) params['priceMax'] = priceMax!.toInt().toString();
    if (language != null && language!.isNotEmpty) params['language'] = language!;
    if (yearsOfExperience != null) params['yearsOfExperience'] = '${yearsOfExperience}_years';
    if (rating != null) params['rating'] = rating!.toInt().toString();
    if (dayOfWeek != null) params['dayOfWeek'] = dayOfWeek!.toString();

    return params;
  }

  // ✅ للـ copyWith في loadMore
  AdvisorFilterRequestModel copyWith({
    double? priceMin,
    double? priceMax,
    String? language,
    int? yearsOfExperience,
    double? rating,
    int? dayOfWeek,
    int? page,
  }) {
    return AdvisorFilterRequestModel(
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      language: language ?? this.language,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      rating: rating ?? this.rating,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      page: page ?? this.page,
    );
  }

  // ✅ للـ toJson لو محتاجه في مكان تاني
  Map<String, dynamic> toJson() => toQueryParams();
}