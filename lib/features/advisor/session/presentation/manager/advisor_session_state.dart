import 'package:tayseer/features/advisor/session/data/models/advisor_session_response.dart';
import 'package:tayseer/my_import.dart';

class AdvisorSessionState {
  CubitStates getadvisorsessionState;
  AdvisorData? advisorData;

  AdvisorSessionState({
    this.getadvisorsessionState = CubitStates.initial,
    this.advisorData,
  });

  AdvisorSessionState copyWith({
    CubitStates? getadvisorsessionState,
    AdvisorData? advisorData,
  }) {
    return AdvisorSessionState(
      getadvisorsessionState:
          getadvisorsessionState ?? this.getadvisorsessionState,
      advisorData: advisorData ?? this.advisorData,
    );
  }
}
