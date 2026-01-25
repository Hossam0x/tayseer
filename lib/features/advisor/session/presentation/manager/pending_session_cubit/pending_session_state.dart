import 'package:tayseer/features/advisor/session/data/models/advisor_session_response.dart';
import 'package:tayseer/features/user/my_space/data/model/pending_session.dart';
import 'package:tayseer/my_import.dart';

class PendingSessionState {
  CubitStates getpendingsessionState;
  PendingSessionData? pendingSessionData;
  CubitStates acceptsessionState;
  AdvisorSession? acceptSessionData;
  String? errormessage;

  PendingSessionState({
    this.getpendingsessionState = CubitStates.initial,
    this.pendingSessionData,
    this.errormessage = '',
    this.acceptsessionState = CubitStates.initial,
    this.acceptSessionData,
  });

  PendingSessionState copyWith({
    CubitStates? getpendingsessionState,
    PendingSessionData? pendingSessionData,
    String? errormessage,
    CubitStates? acceptsessionState,
    AdvisorSession? acceptSessionData,
  }) {
    return PendingSessionState(
      getpendingsessionState:
          getpendingsessionState ?? this.getpendingsessionState,
      pendingSessionData: pendingSessionData ?? this.pendingSessionData,
      errormessage: errormessage ?? this.errormessage,
      acceptsessionState: acceptsessionState ?? this.acceptsessionState,
      acceptSessionData: acceptSessionData ?? this.acceptSessionData,
    );
  }
}
