import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';

class MarriageState extends Equatable {
  final CubitStates marriageProfileState;
  final CubitStates userInteractionState;
  final CubitStates sendRegardState;
  final CubitStates sendRegardTextState;
  final UsersMarriageResponse? profile;
  final String? errorMessage;

  const MarriageState({
    this.marriageProfileState = CubitStates.initial,
    this.userInteractionState = CubitStates.initial,
    this.sendRegardState = CubitStates.initial,
    this.sendRegardTextState = CubitStates.initial,
    this.profile,
    this.errorMessage,
  });

  MarriageState copyWith({
    CubitStates? marriageProfileState,
    CubitStates? userInteractionState,
    CubitStates? sendRegardState,
    CubitStates? sendRegardTextState,
    UsersMarriageResponse? profile,
    String? errorMessage,
  }) {
    return MarriageState(
      marriageProfileState: marriageProfileState ?? this.marriageProfileState,
      userInteractionState: userInteractionState ?? this.userInteractionState,
      sendRegardState: sendRegardState ?? this.sendRegardState,
      sendRegardTextState: sendRegardTextState ?? this.sendRegardTextState,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    marriageProfileState,
    userInteractionState,
    sendRegardState,
    profile,
    errorMessage,
  ];
}
