import 'package:tayseer/features/advisor/session/data/repos/advisor_session_repo.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/advisor_session_detailes_state.dart';
import 'package:tayseer/my_import.dart';

class AdvisorSessionDetailesCubit extends Cubit<AdvisorSessionDetailesState> {
  final AdvisorSessionRepo advisorSessionRepository;

  AdvisorSessionDetailesCubit({required this.advisorSessionRepository})
    : super(const AdvisorSessionDetailesState());

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
