import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/home/model/Image_and_name_model.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/user/my_space/data/model/session_start_model.dart';

import '../../../../my_import.dart';

/// حالة عملية الشير

class HomeState extends Equatable {
  final CubitStates postsState;
  final List<PostModel> posts;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final SessionStartModel? sessionStartModel;

  // 📌 حالة الشير
  final CubitStates shareActionState;
  final String? shareMessage;
  final bool? isShareAdded; // true = تمت الإضافة، false = تمت الإزالة
  final String? sharePostId;

  // fetch name and image
  final ImageAndNameModel? homeInfo;
  final CubitStates fetchNameAndImageState;

  const HomeState({
    this.postsState = CubitStates.initial,
    this.posts = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.shareActionState = CubitStates.initial,
    this.shareMessage,
    this.isShareAdded,
    this.sharePostId,
    //
    this.homeInfo,
    this.fetchNameAndImageState = CubitStates.initial,
    this.sessionStartModel,
  });

  HomeState copyWith({
    CubitStates? postsState,
    List<PostModel>? posts,
    String? errorMessage,
    bool? isConnected,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    CubitStates? shareActionState,
    String? shareMessage,
    bool? isShareAdded,
    String? sharePostId,
    SessionStartModel? sessionStartModel,
    ImageAndNameModel? homeInfo,
    CubitStates? fetchNameAndImageState,
  }) {
    return HomeState(
      postsState: postsState ?? this.postsState,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      shareActionState: shareActionState ?? this.shareActionState,
      shareMessage: shareMessage ?? this.shareMessage,
      isShareAdded: isShareAdded ?? this.isShareAdded,
      sharePostId: sharePostId ?? this.sharePostId,
      homeInfo: homeInfo ?? this.homeInfo,
      fetchNameAndImageState:
          fetchNameAndImageState ?? this.fetchNameAndImageState,
      sessionStartModel: sessionStartModel ?? this.sessionStartModel,
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
    shareActionState,
    shareMessage,
    isShareAdded,
    sharePostId,
    homeInfo,
    fetchNameAndImageState,
    sessionStartModel,
  ];
}
