import 'package:equatable/equatable.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/features/user/advisor_profile/data/models/user_profile_model.dart';
import 'package:tayseer/my_import.dart';

class UserProfileState extends Equatable {
  final CubitStates profileState;
  final UserProfileModel? profile;
  final String? profileErrorMessage;

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

  const UserProfileState({
    this.profileState = CubitStates.initial,
    this.profile,
    this.profileErrorMessage,
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
  });

  UserProfileState copyWith({
    CubitStates? profileState,
    UserProfileModel? profile,
    String? profileErrorMessage,
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
  }) {
    return UserProfileState(
      profileState: profileState ?? this.profileState,
      profile: profile ?? this.profile,
      profileErrorMessage: profileErrorMessage ?? this.profileErrorMessage,
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
    followActionState,
    followMessage,
    isFollowAdded,
    shareActionState,
    shareMessage,
    isShareAdded,
  ];
}
