import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';

class MarriageState extends Equatable {
  final CubitStates marriageProfileState;
  final CubitStates userInteractionState;
  final CubitStates sendRegardState;
  final CubitStates sendRegardTextState;
  final UsersMarriageResponse? profile;
  final int currentIndex;
  final bool isScrollingDown;
  final bool isMarriageTab;
  final String? errorMessage;
  final double swipeDirection;
  final double swipeProgress;
  final bool isAnimating;
  final bool showHistory;
  final String selectedHistoryFilter;
  final List<UserItem> allUsers;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final Map<String, dynamic> activeFilters; // ✅

  const MarriageState({
    this.marriageProfileState = CubitStates.initial,
    this.userInteractionState = CubitStates.initial,
    this.sendRegardState = CubitStates.initial,
    this.sendRegardTextState = CubitStates.initial,
    this.profile,
    this.currentIndex = 0,
    this.isScrollingDown = false,
    this.isMarriageTab = true,
    this.errorMessage,
    this.swipeDirection = 0,
    this.swipeProgress = 0,
    this.isAnimating = false,
    this.showHistory = false,
    this.selectedHistoryFilter = "liked_you",
    this.allUsers = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.activeFilters = const {}, // ✅
  });

  MarriageState copyWith({
    CubitStates? marriageProfileState,
    CubitStates? userInteractionState,
    CubitStates? sendRegardState,
    CubitStates? sendRegardTextState,
    UsersMarriageResponse? profile,
    int? currentIndex,
    bool? isScrollingDown,
    bool? isMarriageTab,
    String? errorMessage,
    double? swipeDirection,
    double? swipeProgress,
    bool? isAnimating,
    bool? showHistory,
    String? selectedHistoryFilter,
    List<UserItem>? allUsers,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    Map<String, dynamic>? activeFilters, // ✅
  }) {
    return MarriageState(
      marriageProfileState: marriageProfileState ?? this.marriageProfileState,
      userInteractionState: userInteractionState ?? this.userInteractionState,
      sendRegardState: sendRegardState ?? this.sendRegardState,
      sendRegardTextState: sendRegardTextState ?? this.sendRegardTextState,
      profile: profile ?? this.profile,
      currentIndex: currentIndex ?? this.currentIndex,
      isScrollingDown: isScrollingDown ?? this.isScrollingDown,
      isMarriageTab: isMarriageTab ?? this.isMarriageTab,
      errorMessage: errorMessage ?? this.errorMessage,
      swipeDirection: swipeDirection ?? this.swipeDirection,
      swipeProgress: swipeProgress ?? this.swipeProgress,
      isAnimating: isAnimating ?? this.isAnimating,
      showHistory: showHistory ?? this.showHistory,
      selectedHistoryFilter:
          selectedHistoryFilter ?? this.selectedHistoryFilter,
      allUsers: allUsers ?? this.allUsers,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      activeFilters: activeFilters ?? this.activeFilters, // ✅
    );
  }

  @override
  List<Object?> get props => [
    marriageProfileState,
    userInteractionState,
    sendRegardState,
    sendRegardTextState,
    profile,
    currentIndex,
    isScrollingDown,
    isMarriageTab,
    errorMessage,
    swipeDirection,
    swipeProgress,
    isAnimating,
    showHistory,
    selectedHistoryFilter,
    allUsers,
    currentPage,
    totalPages,
    isLoadingMore,
    activeFilters, // ✅
  ];
}
