import 'dart:async';

import 'package:tayseer/features/advisor/session/data/models/advisor_session_response.dart';
import 'package:tayseer/features/advisor/session/data/repos/advisor_session_repo.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/advisor_session_state.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/pending_session_cubit/accept_or_declne_session_event_bus.dart';
import 'package:tayseer/my_import.dart';

class AdvisorSessionCubit extends Cubit<AdvisorSessionState> {
  final AdvisorSessionRepo advisorSessionRepository;
  StreamSubscription<AdvisorSession>? _acceptSessionSubscription;

  AdvisorSessionCubit({required this.advisorSessionRepository})
    : super(AdvisorSessionState()) {
    _listenToacceptSessionEvents();
  }

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

  void _listenToacceptSessionEvents() {
    _acceptSessionSubscription = AcceptOrDeclneSessionEventBus
        .instance
        .onacceptSession
        .listen(_addSessionLocally);
  }

  void _addSessionLocally(AdvisorSession acceptSessionData) {
    if (state.advisorData == null) return;

    final updatedNotExpired = [
      acceptSessionData,
      ...state.advisorData!.advisorSessionNotExpired,
    ];

    final updatedAdvisorData = AdvisorData(
      advisorSessionExpired: state.advisorData!.advisorSessionExpired,
      advisorSessionNotExpired: updatedNotExpired,
      advisorTimezone: state.advisorData!.advisorTimezone,
      pendingSessionscount: state.advisorData!.pendingSessionscount,
    );

    emit(state.copyWith(advisorData: updatedAdvisorData));
  }

  @override
  Future<void> close() {
    _acceptSessionSubscription?.cancel();
    return super.close();
  }
}
