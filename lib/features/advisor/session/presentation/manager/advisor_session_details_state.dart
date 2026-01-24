import 'package:tayseer/features/advisor/session/data/models/advisor_details_session_response_model.dart';
import 'package:tayseer/my_import.dart';

class AdvisorSessionDetailsState {
  final CubitStates loadingState;
  final AdvisorSessionDetailsData? sessionDetails;
  final String? errorMessage;

  const AdvisorSessionDetailsState({
    this.loadingState = CubitStates.initial,
    this.sessionDetails,
    this.errorMessage,
  });

  AdvisorSessionDetailsState copyWith({
    CubitStates? loadingState,
    AdvisorSessionDetailsData? sessionDetails,
    String? errorMessage,
  }) {
    return AdvisorSessionDetailsState(
      loadingState: loadingState ?? this.loadingState,
      sessionDetails: sessionDetails ?? this.sessionDetails,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => loadingState == CubitStates.loading;
  bool get isSuccess => loadingState == CubitStates.success;
  bool get isFailure => loadingState == CubitStates.failure;
}
