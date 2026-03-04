// marriage_state.dart
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

  // ═══ الحقول الجديدة ═══
  final double swipeDirection; // 1 = يمين، -1 = شمال، 0 = ثبات
  final double swipeProgress; // 0 → 1
  final bool isAnimating;
  final bool showHistory;
  final String selectedHistoryFilter;

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
  ];
}
