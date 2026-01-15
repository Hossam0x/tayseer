import 'package:equatable/equatable.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/my_import.dart';

class ProfileState extends Equatable {
  final CubitStates postsState;
  final List<PostModel> posts;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const ProfileState({
    this.postsState = CubitStates.initial,
    this.posts = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  ProfileState copyWith({
    CubitStates? postsState,
    List<PostModel>? posts,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProfileState(
      postsState: postsState ?? this.postsState,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    postsState,
    posts,
    errorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
  ];
}
