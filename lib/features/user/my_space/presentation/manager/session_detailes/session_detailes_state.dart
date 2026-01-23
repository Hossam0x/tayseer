import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';

class SessionDetailesState {
  CubitStates getSessionDetailesState;
  CubitStates cancelSession;
  SessionDetailsDataResponse? sessionDetailsData;
  String? errorMessage;
  SessionDetailesState({
    this.getSessionDetailesState = CubitStates.initial,
    this.cancelSession = CubitStates.initial,
    this.sessionDetailsData,
    this.errorMessage,
  });
  SessionDetailesState copyWith({
    CubitStates? getSessionDetailesState,
    CubitStates? cancelSession,
    SessionDetailsDataResponse? sessionDetailsData,
    String? errorMessage,
  }) {
    return SessionDetailesState(
      getSessionDetailesState:
          getSessionDetailesState ?? this.getSessionDetailesState,
      cancelSession: cancelSession ?? this.cancelSession,
      sessionDetailsData: sessionDetailsData ?? this.sessionDetailsData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
