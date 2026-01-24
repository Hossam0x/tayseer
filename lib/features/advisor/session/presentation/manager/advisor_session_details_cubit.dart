import 'package:tayseer/features/advisor/session/data/repos/advisor_session_repo.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/advisor_session_details_state.dart';
import 'package:tayseer/my_import.dart';

class AdvisorSessionDetailsCubit extends Cubit<AdvisorSessionDetailsState> {
  final AdvisorSessionRepo advisorSessionRepository;

  AdvisorSessionDetailsCubit({required this.advisorSessionRepository})
    : super(const AdvisorSessionDetailsState());

  Future<void> getSessionDetails(String sessionId) async {
    emit(state.copyWith(loadingState: CubitStates.loading));
    try {
      final response = await advisorSessionRepository.getAdvisorSessionDetails(
        sessionId,
      );
      response.fold(
        (failure) {
          emit(
            state.copyWith(
              loadingState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (sessionDetailsModel) {
          emit(
            state.copyWith(
              loadingState: CubitStates.success,
              sessionDetails: sessionDetailsModel.data,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadingState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
