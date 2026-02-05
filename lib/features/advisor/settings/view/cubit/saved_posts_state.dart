import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/models/post_model.dart';

class SavedPostsState extends Equatable {
  final CubitStates status;
  final List<PostModel> posts;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

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

  const SavedPostsState({
    this.status = CubitStates.initial,
    this.posts = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,

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

  SavedPostsState copyWith({
    CubitStates? status,
    List<PostModel>? posts,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,

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
    return SavedPostsState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,

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
    status,
    posts,
    errorMessage,
    currentPage,
    hasMore,
    isLoadingMore,

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
