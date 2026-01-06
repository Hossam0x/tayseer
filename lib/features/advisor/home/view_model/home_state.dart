import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';

import '../../../../my_import.dart';

class HomeState extends Equatable {
  final CubitStates postsState;
  final List<PostModel> posts;
  final String? errorMessage;
  final bool isConnected;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const HomeState({
    this.postsState = CubitStates.initial,
    this.posts = const [],
    this.errorMessage,
    this.isConnected = true,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  HomeState copyWith({
    CubitStates? postsState,
    List<PostModel>? posts,
    String? errorMessage,
    bool? isConnected,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HomeState(
      postsState: postsState ?? this.postsState,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      isConnected: isConnected ?? this.isConnected,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  List<Object?> get props => [
    postsState,
    posts,
    errorMessage,
    isConnected,
    currentPage,
    hasMore,
    isLoadingMore,
  ];
}
