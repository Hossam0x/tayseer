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
  ];
}
