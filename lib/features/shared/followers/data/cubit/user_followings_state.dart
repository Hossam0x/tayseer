import 'package:equatable/equatable.dart';
import 'package:tayseer/features/shared/followers/data/models/follower_model.dart';
import 'package:tayseer/my_import.dart';

class UserFollowingsState extends Equatable {
  final CubitStates status;
  final List<FollowerModel> followings;
  final String? errorMessage;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasMore;
  final int currentPage;
  final bool isSearching;
  final String searchQuery;

  const UserFollowingsState({
    this.status = CubitStates.initial,
    this.followings = const [],
    this.errorMessage,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.isSearching = false,
    this.searchQuery = '',
  });

  UserFollowingsState copyWith({
    CubitStates? status,
    List<FollowerModel>? followings,
    String? errorMessage,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasMore,
    int? currentPage,
    bool? isSearching,
    String? searchQuery,
  }) {
    return UserFollowingsState(
      status: status ?? this.status,
      followings: followings ?? this.followings,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    status,
    followings,
    errorMessage,
    isLoading,
    isLoadingMore,
    isRefreshing,
    hasMore,
    currentPage,
    isSearching,
    searchQuery,
  ];
}
