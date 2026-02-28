import 'package:equatable/equatable.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_model.dart';
import 'package:tayseer/features/advisor/profille/data/models/analytics_model.dart';
import 'package:tayseer/my_import.dart';

class ProfileState extends Equatable {
  final CubitStates profileState;
  final ProfileModel? profile;
  final String? profileErrorMessage;

  final CubitStates postsState;
  final List<PostModel> posts;
  final String? postsErrorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  final CubitStates shareActionState;
  final String? shareMessage;
  final bool? isShareAdded;
  final String? sharePostId;

  final CubitStates analyticsState;
  final AnalyticsModel? analytics;
  final String? analyticsErrorMessage;

  // 🛡️ Post Actions Status (جديد)
  final CubitStates saveActionState;
  final String? saveMessage;

  final CubitStates deletePostActionState;
  final String? deletePostMessage;

  final CubitStates blockUserActionState;
  final String? blockUserMessage;

  final CubitStates archivePostActionState;
  final String? archivePostMessage;

  const ProfileState({
    this.profileState = CubitStates.initial,
    this.profile,
    this.profileErrorMessage,
    this.postsState = CubitStates.initial,
    this.posts = const [],
    this.postsErrorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.shareActionState = CubitStates.initial,
    this.shareMessage,
    this.isShareAdded,
    this.sharePostId,
    this.analyticsState = CubitStates.initial,
    this.analytics,
    this.analyticsErrorMessage,
    this.saveActionState = CubitStates.initial,
    this.saveMessage,
    this.deletePostActionState = CubitStates.initial,
    this.deletePostMessage,
    this.blockUserActionState = CubitStates.initial,
    this.blockUserMessage,
    this.archivePostActionState = CubitStates.initial,
    this.archivePostMessage,
  });

  ProfileState copyWith({
    CubitStates? profileState,
    ProfileModel? profile,
    String? profileErrorMessage,
    CubitStates? postsState,
    List<PostModel>? posts,
    String? postsErrorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    CubitStates? shareActionState,
    String? shareMessage,
    bool? isShareAdded,
    String? sharePostId,
    CubitStates? analyticsState,
    AnalyticsModel? analytics,
    String? analyticsErrorMessage,
    CubitStates? saveActionState,
    String? saveMessage,
    CubitStates? deletePostActionState,
    String? deletePostMessage,
    CubitStates? blockUserActionState,
    String? blockUserMessage,
    CubitStates? archivePostActionState,
    String? archivePostMessage,
  }) {
    return ProfileState(
      profileState: profileState ?? this.profileState,
      profile: profile ?? this.profile,
      profileErrorMessage: profileErrorMessage ?? this.profileErrorMessage,
      postsState: postsState ?? this.postsState,
      posts: posts ?? this.posts,
      postsErrorMessage: postsErrorMessage ?? this.postsErrorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      shareActionState: shareActionState ?? this.shareActionState,
      shareMessage: shareMessage ?? this.shareMessage,
      isShareAdded: isShareAdded ?? this.isShareAdded,
      sharePostId: sharePostId ?? this.sharePostId,
      analyticsState: analyticsState ?? this.analyticsState,
      analytics: analytics ?? this.analytics,
      analyticsErrorMessage:
          analyticsErrorMessage ?? this.analyticsErrorMessage,
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
    profileState,
    profile,
    profileErrorMessage,
    postsState,
    posts,
    postsErrorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
    shareActionState,
    shareMessage,
    isShareAdded,
    sharePostId,
    analyticsState,
    analytics,
    analyticsErrorMessage,
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
