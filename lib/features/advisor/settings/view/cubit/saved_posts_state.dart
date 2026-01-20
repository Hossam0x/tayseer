import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';

class SavedPostsState extends Equatable {
  final CubitStates status;
  final List<PostModel> posts;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  // ⭐️ أضف Share State
  final CubitStates shareActionState;
  final String? shareMessage;
  final bool? isShareAdded;

  const SavedPostsState({
    this.status = CubitStates.initial,
    this.posts = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    // ⭐️
    this.shareActionState = CubitStates.initial,
    this.shareMessage,
    this.isShareAdded,
  });

  SavedPostsState copyWith({
    CubitStates? status,
    List<PostModel>? posts,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    // ⭐️
    CubitStates? shareActionState,
    String? shareMessage,
    bool? isShareAdded,
  }) {
    return SavedPostsState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      // ⭐️
      shareActionState: shareActionState ?? this.shareActionState,
      shareMessage: shareMessage ?? this.shareMessage,
      isShareAdded: isShareAdded ?? this.isShareAdded,
    );
  }

  @override
  List<Object?> get props => [
    status,
    posts,
    errorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
    shareActionState,
    shareMessage,
    isShareAdded,
  ];
}
