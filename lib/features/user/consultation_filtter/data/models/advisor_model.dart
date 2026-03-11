// lib/features/user/consultation/data/models/advisor_model.dart
class AdvisorFilterModel {
  final int id;
  final String name;
  final String specialty;
  final String? imageUrl;
  final double rating;
  final int reviewsCount;
  final double pricePerHour;
  final String experience;
  final List<String> languages;
  final List<String> badges;
  final bool isRecommended;

  const AdvisorFilterModel({
    required this.id,
    required this.name,
    required this.specialty,
    this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    required this.pricePerHour,
    required this.experience,
    required this.languages,
    required this.badges,
    this.isRecommended = false,
  });

  factory AdvisorFilterModel.fromJson(Map<String, dynamic> json) {
    return AdvisorFilterModel(
      id: json['id'] as int,
      name: json['name'] as String,
      specialty: json['specialty'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviews_count'] as int? ?? 0,
      pricePerHour: (json['price_per_hour'] as num).toDouble(),
      experience: json['experience'] as String? ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      badges: List<String>.from(json['badges'] ?? []),
      isRecommended: json['is_recommended'] as bool? ?? false,
    );
  }
  
}

// ─── Paginated Response ───────────────────────────────────────────────────────

class PaginatedAdvisorsModel {
  final List<AdvisorFilterModel> advisors;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedAdvisorsModel({
    required this.advisors,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasNextPage => currentPage < lastPage;

  factory PaginatedAdvisorsModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawList = json['data'] as List<dynamic>;
    return PaginatedAdvisorsModel(
      advisors: rawList
          .map((e) => AdvisorFilterModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      total: json['total'] as int,
    );
  }
}