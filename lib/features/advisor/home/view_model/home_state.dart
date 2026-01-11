import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';

import '../../../../my_import.dart';

/// حالة عملية الشير

class HomeState extends Equatable {
  final CubitStates postsState;
  final List<PostModel> posts;
  final String? errorMessage;
  final bool isConnected;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  // 📌 حالة الشير
  final CubitStates shareActionState;
  final String? shareMessage;
  final bool? isShareAdded; // true = تمت الإضافة، false = تمت الإزالة
  final String? sharePostId;

  const HomeState({
    this.postsState = CubitStates.initial,
    this.posts = const [],
    this.errorMessage,
    this.isConnected = true,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.shareActionState = CubitStates.initial,
    this.shareMessage,
    this.isShareAdded,
    this.sharePostId,
  });

  HomeState copyWith({
    CubitStates? postsState,
    List<PostModel>? posts,
    String? errorMessage,
    bool? isConnected,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    CubitStates? shareActionState,
    String? shareMessage,
    bool? isShareAdded,
    String? sharePostId,
  }) {
    return HomeState(
      postsState: postsState ?? this.postsState,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      isConnected: isConnected ?? this.isConnected,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      shareActionState: shareActionState ?? this.shareActionState,
      shareMessage: shareMessage ?? this.shareMessage,
      isShareAdded: isShareAdded ?? this.isShareAdded,
      sharePostId: sharePostId ?? this.sharePostId,
    );
  }

  @override
  List<Object?> get props => [
    postsState,
    posts,
    errorMessage,
    isConnected,
    currentPage,
    hasMore,
    isLoadingMore,
    shareActionState,
    shareMessage,
    isShareAdded,
    sharePostId,
  ];
}
