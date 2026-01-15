import 'package:equatable/equatable.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_model.dart';
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
  });

  // Getter للتحقق من وجود خطأ
  bool get hasProfileError => profileErrorMessage != null;
  bool get hasPostsError => postsErrorMessage != null;
  bool get hasAnyError => hasProfileError || hasPostsError;

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
  ];
}
