import 'package:tayseer/features/advisor/session/data/models/advisor_session_response.dart';
import 'package:tayseer/features/user/my_space/data/model/pending_session.dart';
import 'package:tayseer/my_import.dart';

class AdvisorSessionState {
  CubitStates getadvisorsessionState;
  CubitStates getpendingsessionState;
  AdvisorData? advisorData;
  PendingSessionData? pendingSessionData;
  String? errormessage;

  AdvisorSessionState({
    this.getadvisorsessionState = CubitStates.initial,
    this.getpendingsessionState = CubitStates.initial,
    this.advisorData,
    this.pendingSessionData,
    this.errormessage = '',
  });

  AdvisorSessionState copyWith({
    CubitStates? getadvisorsessionState,
    CubitStates? getpendingsessionState,
    AdvisorData? advisorData,
    PendingSessionData? pendingSessionData,
    String? errormessage,
  }) {
    return AdvisorSessionState(
      getadvisorsessionState:
          getadvisorsessionState ?? this.getadvisorsessionState,
      getpendingsessionState:
          getpendingsessionState ?? this.getpendingsessionState,
      advisorData: advisorData ?? this.advisorData,
      pendingSessionData: pendingSessionData ?? this.pendingSessionData,
      errormessage: errormessage ?? this.errormessage,
    );
  }
}
