import 'package:tayseer/features/advisor/session/data/repos/advisor_session_repo.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/advisor_session_state.dart';
import 'package:tayseer/my_import.dart';

class AdvisorSessionCubit extends Cubit<AdvisorSessionState> {
  final AdvisorSessionRepo advisorSessionRepository;

  AdvisorSessionCubit({required this.advisorSessionRepository})
    : super(AdvisorSessionState());

  Future<void> getAdvisorSessions() async {
    emit(state.copyWith(getadvisorsessionState: CubitStates.loading));
    try {
      final response = await advisorSessionRepository.getSessions();
      response.fold(
        (failure) {
          emit(state.copyWith(getadvisorsessionState: CubitStates.failure));
        },
        (advisorSessionsModel) {
          emit(
            state.copyWith(
              getadvisorsessionState: CubitStates.success,
              advisorData: advisorSessionsModel.advisorData,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(getadvisorsessionState: CubitStates.failure));
    }
  }
}
