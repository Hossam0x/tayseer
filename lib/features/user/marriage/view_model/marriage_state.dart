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
    );
  }

  @override
  List<Object?> get props => [
    marriageProfileState,
    userInteractionState,
    sendRegardState,
    profile,
    currentIndex,
    isScrollingDown,
    isMarriageTab,
    errorMessage,
  ];
}
