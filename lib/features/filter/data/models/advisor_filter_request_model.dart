// lib/features/advisor_filter/data/models/advisor_filter_request_model.dart

class AdvisorFilterRequestModel {
  final double minPrice;
  final double maxPrice;
  final String? experience;
  final int? rating;       // null = no filter, 1-5 = selected rating
  final List<String> languages;
  final List<String> badges;
  final String date;       // "2024-01-15"
  final int page;
  final int perPage;

  const AdvisorFilterRequestModel({
    required this.minPrice,
    required this.maxPrice,
    this.experience,
    this.rating,
    required this.languages,
    required this.badges,
    required this.date,
    this.page = 1,
    this.perPage = 10,
  });
// ✅ copyWith مضافة
  AdvisorFilterRequestModel copyWith({
    double? minPrice,
    double? maxPrice,
    String? experience,
    int? rating,
    List<String>? languages,
    List<String>? badges,
    String? date,
    int? page,
    int? perPage,
  }) {
    return AdvisorFilterRequestModel(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      experience: experience ?? this.experience,
      rating: rating ?? this.rating,
      languages: languages ?? this.languages,
      badges: badges ?? this.badges,
      date: date ?? this.date,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'min_price': minPrice,
      'max_price': maxPrice,
      if (experience != null) 'experience': experience,
      if (rating != null) 'rating': rating,
      if (languages.isNotEmpty) 'languages': languages,
      if (badges.isNotEmpty) 'badges': badges,
      'date': date,
      'page': page,
      'per_page': perPage,
    };
  }

  @override
  String toString() => toJson().toString();
}