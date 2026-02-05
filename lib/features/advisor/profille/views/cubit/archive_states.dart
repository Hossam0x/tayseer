import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/advisor/profille/data/models/archive_models.dart';
import 'package:tayseer/core/models/post_model.dart';

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
  final List<PostModel> posts;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  // 🛡️ Post Actions Status
  final CubitStates shareActionState;
  final String? shareMessage;
  final bool? isShareAdded;
  final String? sharePostId;

  final CubitStates saveActionState;
  final String? saveMessage;

  final CubitStates deletePostActionState;
  final String? deletePostMessage;

  final CubitStates blockUserActionState;
  final String? blockUserMessage;

  final CubitStates archivePostActionState;
  final String? archivePostMessage;

  const ArchivedPostsState({
    this.state = CubitStates.initial,
    this.posts = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,

    this.shareActionState = CubitStates.initial,
    this.shareMessage,
    this.isShareAdded,
    this.sharePostId,

    this.saveActionState = CubitStates.initial,
    this.saveMessage,

    this.deletePostActionState = CubitStates.initial,
    this.deletePostMessage,

    this.blockUserActionState = CubitStates.initial,
    this.blockUserMessage,

    this.archivePostActionState = CubitStates.initial,
    this.archivePostMessage,
  });

  ArchivedPostsState copyWith({
    CubitStates? state,
    List<PostModel>? posts,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,

    CubitStates? shareActionState,
    String? shareMessage,
    bool? isShareAdded,
    String? sharePostId,

    CubitStates? saveActionState,
    String? saveMessage,

    CubitStates? deletePostActionState,
    String? deletePostMessage,

    CubitStates? blockUserActionState,
    String? blockUserMessage,

    CubitStates? archivePostActionState,
    String? archivePostMessage,
  }) {
    return ArchivedPostsState(
      state: state ?? this.state,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,

      shareActionState: shareActionState ?? this.shareActionState,
      shareMessage: shareMessage ?? this.shareMessage,
      isShareAdded: isShareAdded ?? this.isShareAdded,
      sharePostId: sharePostId ?? this.sharePostId,

      saveActionState: saveActionState ?? this.saveActionState,
      saveMessage: saveMessage ?? this.saveMessage,

      deletePostActionState:
          deletePostActionState ?? this.deletePostActionState,
      deletePostMessage: deletePostMessage ?? this.deletePostMessage,

      blockUserActionState: blockUserActionState ?? this.blockUserActionState,
      blockUserMessage: blockUserMessage ?? this.blockUserMessage,

      archivePostActionState:
          archivePostActionState ?? this.archivePostActionState,
      archivePostMessage: archivePostMessage ?? this.archivePostMessage,
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

    shareActionState,
    shareMessage,
    isShareAdded,
    sharePostId,

    saveActionState,
    saveMessage,

    deletePostActionState,
    deletePostMessage,

    blockUserActionState,
    blockUserMessage,

    archivePostActionState,
    archivePostMessage,
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
