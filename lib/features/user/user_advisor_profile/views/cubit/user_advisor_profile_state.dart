import 'package:equatable/equatable.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/user/user_advisor_profile/data/models/user_advisor_profile_model.dart';
import 'package:tayseer/my_import.dart';

class UserAdvisorProfileState extends Equatable {
  final CubitStates profileState;
  final UserAdvisorProfileModel? profile;
  final String? profileErrorMessage;
  final String? chatRoomId;

  final CubitStates postsState;
  final List<PostModel> posts;
  final String? postsErrorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  final CubitStates followActionState;
  final String? followMessage;
  final bool? isFollowAdded;

  final CubitStates shareActionState;
  final String? shareMessage;
  final bool? isShareAdded;

  final bool shouldNavigateToChat;

  final bool isChatLoading;

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

  const UserAdvisorProfileState({
    this.profileState = CubitStates.initial,
    this.profile,
    this.profileErrorMessage,
    this.chatRoomId,
    this.postsState = CubitStates.initial,
    this.posts = const [],
    this.postsErrorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.followActionState = CubitStates.initial,
    this.followMessage,
    this.isFollowAdded,
    this.shareActionState = CubitStates.initial,
    this.shareMessage,
    this.isShareAdded,
    this.shouldNavigateToChat = false,
    this.isChatLoading = false,
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
  });

  bool get hasRoom => profile?.hasRoom == true;

  UserAdvisorProfileState copyWith({
    CubitStates? profileState,
    UserAdvisorProfileModel? profile,
    String? profileErrorMessage,
    String? chatRoomId,
    CubitStates? postsState,
    List<PostModel>? posts,
    String? postsErrorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    CubitStates? followActionState,
    String? followMessage,
    bool? isFollowAdded,
    CubitStates? shareActionState,
    String? shareMessage,
    bool? isShareAdded,
    bool? shouldNavigateToChat,
    bool? isChatLoading,
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
  }) {
    return UserAdvisorProfileState(
      profileState: profileState ?? this.profileState,
      profile: profile ?? this.profile,
      profileErrorMessage: profileErrorMessage ?? this.profileErrorMessage,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      postsState: postsState ?? this.postsState,
      posts: posts ?? this.posts,
      postsErrorMessage: postsErrorMessage ?? this.postsErrorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      followActionState: followActionState ?? this.followActionState,
      followMessage: followMessage ?? this.followMessage,
      isFollowAdded: isFollowAdded ?? this.isFollowAdded,
      shareActionState: shareActionState ?? this.shareActionState,
      shareMessage: shareMessage ?? this.shareMessage,
      isShareAdded: isShareAdded ?? this.isShareAdded,
      shouldNavigateToChat: shouldNavigateToChat ?? this.shouldNavigateToChat,
      isChatLoading: isChatLoading ?? this.isChatLoading,
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
    );
  }

  @override
  List<Object?> get props => [
    profileState,
    profile,
    profileErrorMessage,
    chatRoomId,
    postsState,
    posts,
    postsErrorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
    followActionState,
    followMessage,
    isFollowAdded,
    shareActionState,
    shareMessage,
    isShareAdded,
    shouldNavigateToChat,
    isChatLoading,
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
  ];
}
