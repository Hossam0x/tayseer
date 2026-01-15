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
      averageRating: (json['averageRating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      starsBreakdown: starsBreakdown.map(
        (key, value) => MapEntry(int.parse(key), value as int),
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
  final int rating;
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
      rating: json['rating'] as int,
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
  final RatingSummaryModel summary;
  final List<RatingModel> ratings;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;

  const RatingsResponseModel({
    required this.summary,
    required this.ratings,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasMore,
  });

  factory RatingsResponseModel.fromJson(Map<String, dynamic> json) {
    final summary = RatingSummaryModel.fromJson(
      Map<String, dynamic>.from(json['summary']),
    );

    final ratingsList = (json['ratings'] as List)
        .map(
          (rating) => RatingModel.fromJson(Map<String, dynamic>.from(rating)),
        )
        .toList();

    final pagination = Map<String, dynamic>.from(json['pagination']);

    return RatingsResponseModel(
      summary: summary,
      ratings: ratingsList,
      currentPage: pagination['currentPage'] as int,
      totalPages: pagination['totalPages'] as int,
      totalCount: pagination['totalCount'] as int,
      hasMore: pagination['currentPage'] < pagination['totalPages'],
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
