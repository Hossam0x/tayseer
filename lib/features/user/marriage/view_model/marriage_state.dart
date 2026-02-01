import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';

class MarriageState extends Equatable {
  final CubitStates state;
  final UsersMarriageResponse? profile;
  final String? errorMessage;

  const MarriageState({
    this.state = CubitStates.initial,
    this.profile,
    this.errorMessage,
  });

  MarriageState copyWith({
    CubitStates? state,
    UsersMarriageResponse? profile,
    String? errorMessage,
  }) {
    return MarriageState(
      state: state ?? this.state,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [state, profile, errorMessage];
}
