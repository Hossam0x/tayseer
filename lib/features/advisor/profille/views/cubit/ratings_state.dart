import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/profille/data/models/rating_model.dart';
import 'package:tayseer/my_import.dart';

class RatingsState extends Equatable {
  final CubitStates state;
  final RatingSummaryModel? summary;
  final List<RatingModel> ratings;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const RatingsState({
    this.state = CubitStates.initial,
    this.summary,
    this.ratings = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  // Getters
  double get averageRating => summary?.averageRating ?? 0.0;
  int get totalRatings => summary?.totalRatings ?? 0;
  Map<int, int> get starsBreakdown => summary?.starsBreakdown ?? {};

  RatingsState copyWith({
    CubitStates? state,
    RatingSummaryModel? summary,
    List<RatingModel>? ratings,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return RatingsState(
      state: state ?? this.state,
      summary: summary ?? this.summary,
      ratings: ratings ?? this.ratings,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    state,
    summary,
    ratings,
    errorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
  ];
}
