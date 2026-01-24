import 'package:tayseer/features/advisor/session/data/models/advisor_detailes_session_response_model.dart';
import 'package:tayseer/my_import.dart';

class AdvisorSessionDetailesState {
  final CubitStates loadingState;
  final AdvisorSessionDetailesData? sessionDetails;
  final String? errorMessage;

  const AdvisorSessionDetailesState({
    this.loadingState = CubitStates.initial,
    this.sessionDetails,
    this.errorMessage,
  });

  AdvisorSessionDetailesState copyWith({
    CubitStates? loadingState,
    AdvisorSessionDetailesData? sessionDetails,
    String? errorMessage,
  }) {
    return AdvisorSessionDetailesState(
      loadingState: loadingState ?? this.loadingState,
      sessionDetails: sessionDetails ?? this.sessionDetails,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => loadingState == CubitStates.loading;
  bool get isSuccess => loadingState == CubitStates.success;
  bool get isFailure => loadingState == CubitStates.failure;
}
