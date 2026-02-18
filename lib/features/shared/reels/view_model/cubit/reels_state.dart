// reels_state.dart
part of 'reels_cubit.dart';

class ReelsState extends Equatable {
  final CubitStates reelsState;
  final List<PostModel> reels;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;
  
  // ✅ Share Action States
  final CubitStates shareActionState;
  final String? shareMessage;
  final bool isShareAdded;

  const ReelsState({
    this.reelsState = CubitStates.initial,
    this.reels = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.errorMessage,
    this.shareActionState = CubitStates.initial,
    this.shareMessage,
    this.isShareAdded = false,
  });

  ReelsState copyWith({
    CubitStates? reelsState,
    List<PostModel>? reels,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
    CubitStates? shareActionState,
    String? shareMessage,
    bool? isShareAdded,
  }) {
    return ReelsState(
      reelsState: reelsState ?? this.reelsState,
      reels: reels ?? this.reels,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      shareActionState: shareActionState ?? this.shareActionState,
      shareMessage: shareMessage ?? this.shareMessage,
      isShareAdded: isShareAdded ?? this.isShareAdded,
    );
  }

  @override
  List<Object?> get props => [
        reelsState,
        reels,
        currentPage,
        hasMore,
        isLoadingMore,
        errorMessage,
        shareActionState,
        shareMessage,
        isShareAdded,
      ];
}