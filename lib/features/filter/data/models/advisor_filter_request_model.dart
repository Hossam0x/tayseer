// lib/features/filter/data/models/advisor_filter_request_model.dart

class AdvisorFilterRequestModel {
  final double? priceMin;
  final double? priceMax;
  final String? language;
  final String? yearsOfExperience; // ✅ String بدل int
  final double? rating;
  final int? dayOfWeek;
  final int page;

  const AdvisorFilterRequestModel({
    this.priceMin,
    this.priceMax,
    this.language,
    this.yearsOfExperience, // ✅
    this.rating,
    this.dayOfWeek,
    this.page = 1,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {'page': page.toString()};

    if (priceMin != null) params['priceMin'] = priceMin!.toInt().toString();
    if (priceMax != null) params['priceMax'] = priceMax!.toInt().toString();
    if (language != null && language!.isNotEmpty)
      params['language'] = language!;

    // ✅ بيبعت 'experience_0_2' مباشرة بدون تعديل
    if (yearsOfExperience != null && yearsOfExperience!.isNotEmpty)
      params['yearsOfExperience'] = yearsOfExperience!;

    if (rating != null) params['rating'] = rating!.toInt().toString();
    if (dayOfWeek != null) params['dayOfWeek'] = dayOfWeek!.toString();

    return params;
  }

  AdvisorFilterRequestModel copyWith({
    double? priceMin,
    double? priceMax,
    String? language,
    String? yearsOfExperience, // ✅ String
    double? rating,
    int? dayOfWeek,
    int? page,
  }) {
    return AdvisorFilterRequestModel(
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      language: language ?? this.language,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience, // ✅
      rating: rating ?? this.rating,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      page: page ?? this.page,
    );
  }

  Map<String, dynamic> toJson() => toQueryParams();
}
