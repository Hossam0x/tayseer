// features/user/user_public_profile/views/cubit/user_public_profile_state.dart
import 'package:equatable/equatable.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/my_import.dart';

class UserPublicProfileState extends Equatable {
  final CubitStates state;
  final UserProfileModel? profile;
  final String? profileErrorMessage;

  final CubitStates profileState;
  final CubitStates postsState;
  final List<PostModel> posts;
  final String? postsErrorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  final CubitStates shareActionState;
  final String? shareMessage;
  final bool? isShareAdded;

  final bool isLoadingDelete;
  final CubitStates saveActionState;
  final String? saveMessage;

  final CubitStates deletePostActionState;
  final String? deletePostMessage;

  final CubitStates archivePostActionState;
  final String? archivePostMessage;

  final CubitStates blockUserActionState;
  final String? blockUserMessage;

  final CubitStates blockActionState;
  final String? blockMessage;
  final CubitStates reportActionState;
  final String? reportMessage;

  final bool isSendingGreeting;
  final String? greetingMessage;
  final bool greetingSuccess;
  final CubitStates pollVoteActionState;
  final String? pollVoteMessage;

  const UserPublicProfileState({
    this.state = CubitStates.initial,
    this.profile,
    this.profileErrorMessage,
    this.profileState = CubitStates.initial,
    this.postsState = CubitStates.initial,
    this.posts = const [],
    this.postsErrorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.shareActionState = CubitStates.initial,
    this.shareMessage,
    this.isShareAdded,
    this.isLoadingDelete = false,
    this.saveActionState = CubitStates.initial,
    this.saveMessage,
    this.deletePostActionState = CubitStates.initial,
    this.deletePostMessage,
    this.archivePostActionState = CubitStates.initial,
    this.archivePostMessage,
    this.blockUserActionState = CubitStates.initial,
    this.blockUserMessage,
    this.blockActionState = CubitStates.initial,
    this.blockMessage,
    this.reportActionState = CubitStates.initial,
    this.reportMessage,
    this.isSendingGreeting = false,
    this.greetingMessage,
    this.greetingSuccess = false,
    this.pollVoteActionState = CubitStates.initial,
    this.pollVoteMessage,
  });

  UserPublicProfileState copyWith({
    CubitStates? state,
    UserProfileModel? profile,
    String? profileErrorMessage,
    CubitStates? profileState,
    CubitStates? postsState,
    List<PostModel>? posts,
    String? postsErrorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    CubitStates? shareActionState,
    String? shareMessage,
    bool? isShareAdded,
    bool? isLoadingDelete,
    CubitStates? saveActionState,
    String? saveMessage,
    CubitStates? deletePostActionState,
    String? deletePostMessage,
    CubitStates? archivePostActionState,
    String? archivePostMessage,
    CubitStates? blockUserActionState,
    String? blockUserMessage,
    CubitStates? blockActionState,
    String? blockMessage,
    CubitStates? reportActionState,
    String? reportMessage,
    bool? isSendingGreeting,
    String? greetingMessage,
    bool? greetingSuccess,
    CubitStates? pollVoteActionState,
    String? pollVoteMessage,
  }) {
    return UserPublicProfileState(
      state: state ?? this.state,
      profile: profile ?? this.profile,
      profileErrorMessage: profileErrorMessage ?? this.profileErrorMessage,
      profileState: profileState ?? this.profileState,
      postsState: postsState ?? this.postsState,
      posts: posts ?? this.posts,
      postsErrorMessage: postsErrorMessage ?? this.postsErrorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      shareActionState: shareActionState ?? this.shareActionState,
      shareMessage: shareMessage ?? this.shareMessage,
      isShareAdded: isShareAdded ?? this.isShareAdded,
      isLoadingDelete: isLoadingDelete ?? this.isLoadingDelete,
      saveActionState: saveActionState ?? this.saveActionState,
      saveMessage: saveMessage ?? this.saveMessage,
      deletePostActionState:
          deletePostActionState ?? this.deletePostActionState,
      deletePostMessage: deletePostMessage ?? this.deletePostMessage,
      archivePostActionState:
          archivePostActionState ?? this.archivePostActionState,
      archivePostMessage: archivePostMessage ?? this.archivePostMessage,
      blockUserActionState: blockUserActionState ?? this.blockUserActionState,
      blockUserMessage: blockUserMessage ?? this.blockUserMessage,
      blockActionState: blockActionState ?? this.blockActionState,
      blockMessage: blockMessage ?? this.blockMessage,
      reportActionState: reportActionState ?? this.reportActionState,
      reportMessage: reportMessage ?? this.reportMessage,
      isSendingGreeting: isSendingGreeting ?? this.isSendingGreeting,
      greetingMessage: greetingMessage ?? this.greetingMessage,
      greetingSuccess: greetingSuccess ?? this.greetingSuccess,
      pollVoteActionState: pollVoteActionState ?? this.pollVoteActionState,
      pollVoteMessage: pollVoteMessage ?? this.pollVoteMessage,
    );
  }

  @override
  List<Object?> get props => [
    state,
    profile,
    profileErrorMessage,
    profileState,
    postsState,
    posts,
    postsErrorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
    shareActionState,
    shareMessage,
    isShareAdded,
    isLoadingDelete,
    saveActionState,
    saveMessage,
    deletePostActionState,
    deletePostMessage,
    archivePostActionState,
    archivePostMessage,
    blockUserActionState,
    blockUserMessage,
    blockActionState,
    blockMessage,
    reportActionState,
    reportMessage,
    isSendingGreeting,
    greetingMessage,
    greetingSuccess,
    pollVoteActionState,
    pollVoteMessage,
  ];
}
