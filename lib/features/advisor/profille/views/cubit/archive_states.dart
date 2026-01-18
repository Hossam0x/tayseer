import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/advisor/profille/data/models/archive_models.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';

// ============================================
// 📌 ARCHIVED CHATS STATE
// ============================================
class ArchivedChatsState extends Equatable {
  final CubitStates state;
  final List<ArchiveChatRoomModel> chatRooms;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  const ArchivedChatsState({
    this.state = CubitStates.initial,
    this.chatRooms = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  ArchivedChatsState copyWith({
    CubitStates? state,
    List<ArchiveChatRoomModel>? chatRooms,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return ArchivedChatsState(
      state: state ?? this.state,
      chatRooms: chatRooms ?? this.chatRooms,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    state,
    chatRooms,
    errorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
    isRefreshing,
  ];
}

// ============================================
// 📌 ARCHIVED POSTS STATE
// ============================================
class ArchivedPostsState extends Equatable {
  final CubitStates state;
  final List<PostModel> posts; // ⭐️ غير من ArchivePostModel إلى PostModel
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  const ArchivedPostsState({
    this.state = CubitStates.initial,
    this.posts = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  ArchivedPostsState copyWith({
    CubitStates? state,
    List<PostModel>? posts,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return ArchivedPostsState(
      state: state ?? this.state,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    state,
    posts,
    errorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
    isRefreshing,
  ];
}

// ============================================
// 📌 ARCHIVED STORIES STATE
// ============================================
class ArchivedStoriesState extends Equatable {
  final CubitStates state;
  final List<ArchiveStoryModel> stories;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  const ArchivedStoriesState({
    this.state = CubitStates.initial,
    this.stories = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  ArchivedStoriesState copyWith({
    CubitStates? state,
    List<ArchiveStoryModel>? stories,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return ArchivedStoriesState(
      state: state ?? this.state,
      stories: stories ?? this.stories,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    state,
    stories,
    errorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
    isRefreshing,
  ];
}
