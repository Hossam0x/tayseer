import 'package:equatable/equatable.dart';

class RatingSummaryModel extends Equatable {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> starsBreakdown;

  const RatingSummaryModel({
    required this.averageRating,
    required this.totalRatings,
    required this.starsBreakdown,
  });

  factory RatingSummaryModel.fromJson(Map<String, dynamic> json) {
    final starsBreakdown = Map<String, dynamic>.from(json['starsBreakdown']);

    return RatingSummaryModel(
      averageRating: double.tryParse(json['averageRating'].toString()) ?? 0.0,
      totalRatings: int.tryParse(json['totalRatings'].toString()) ?? 0,
      starsBreakdown: starsBreakdown.map(
        (key, value) => MapEntry(
          int.tryParse(key.toString()) ?? 0,
          int.tryParse(value.toString()) ?? 0,
        ),
      ),
    );
  }

  @override
  List<Object?> get props => [averageRating, totalRatings, starsBreakdown];
}

class RatingUserModel extends Equatable {
  final String id;
  final String? image;
  final String? name;

  const RatingUserModel({required this.id, this.image, this.name});

  factory RatingUserModel.fromJson(Map<String, dynamic> json) {
    return RatingUserModel(
      id: json['id'] as String,
      image: json['image'] as String?,
      name: json['name'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, image, name];
}

class RatingModel extends Equatable {
  final String id;
  final double rating;
  final String review;
  final String createdAt;
  final bool isOwner;
  final RatingUserModel user;

  const RatingModel({
    required this.id,
    required this.rating,
    required this.review,
    required this.createdAt,
    required this.isOwner,
    required this.user,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String,
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      review: json['review'] as String,
      createdAt: json['createdAt'] as String,
      isOwner: json['isOwner'] as bool,
      user: RatingUserModel.fromJson(Map<String, dynamic>.from(json['user'])),
    );
  }

  @override
  List<Object?> get props => [id, rating, review, createdAt, isOwner, user];
}

class RatingsResponseModel extends Equatable {
  final RatingSummaryModel? summary;
  final List<RatingModel> ratings;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;

  const RatingsResponseModel({
    this.summary,
    required this.ratings,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasMore,
  });

  factory RatingsResponseModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] != null
        ? RatingSummaryModel.fromJson(
            Map<String, dynamic>.from(json['summary']),
          )
        : null;

    final ratingsList = (json['ratings'] as List)
        .map(
          (rating) => RatingModel.fromJson(Map<String, dynamic>.from(rating)),
        )
        .toList();

    final pagination = Map<String, dynamic>.from(json['pagination']);

    return RatingsResponseModel(
      summary: summary,
      ratings: ratingsList,
      currentPage: int.tryParse(pagination['currentPage'].toString()) ?? 1,
      totalPages: int.tryParse(pagination['totalPages'].toString()) ?? 1,
      totalCount: int.tryParse(pagination['totalCount'].toString()) ?? 0,
      hasMore:
          (int.tryParse(pagination['currentPage'].toString()) ?? 1) <
          (int.tryParse(pagination['totalPages'].toString()) ?? 1),
    );
  }

  @override
  List<Object?> get props => [
    summary,
    ratings,
    currentPage,
    totalPages,
    totalCount,
    hasMore,
  ];
}
