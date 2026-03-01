import 'dart:developer';

import 'package:tayseer/features/advisor/session/data/repos/advisor_session_repo.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/pending_session_cubit/accept_or_declne_session_event_bus.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/pending_session_cubit/pending_session_state.dart';
import 'package:tayseer/my_import.dart';

class PendingSessionCubit extends Cubit<PendingSessionState> {
  final AdvisorSessionRepo advisorSessionRepository;

  PendingSessionCubit({required this.advisorSessionRepository})
    : super(PendingSessionState());

  Future<void> getPendingSession() async {
    emit(state.copyWith(getpendingsessionState: CubitStates.loading));
    try {
      final response = await advisorSessionRepository.getpendingsession();
      response.fold(
        (failure) {
          emit(state.copyWith(getpendingsessionState: CubitStates.failure));
        },
        (pendingSessionData) {
          emit(
            state.copyWith(
              getpendingsessionState: CubitStates.success,
              pendingSessionData: pendingSessionData.data,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(getpendingsessionState: CubitStates.failure));
    }
  }

  Future<void> acceptSession(String sessionId, String status) async {
    final originalPendingSessions = state.pendingSessionData?.pendingSessions;
    final originalCount = state.pendingSessionData?.count ?? 0;

    final updatedPendingSessions = originalPendingSessions
        ?.where((session) => session.sessionId != sessionId)
        .toList();

    emit(
      state.copyWith(
        acceptsessionState: CubitStates.loading,
        pendingSessionData: state.pendingSessionData?.copyWith(
          pendingSessions: updatedPendingSessions,
          count: originalCount - 1,
        ),
      ),
    );

    try {
      final response = await advisorSessionRepository.acceptordeclinesession(
        sessionId,
        status,
      );

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              acceptsessionState: CubitStates.failure,
              pendingSessionData: state.pendingSessionData?.copyWith(
                pendingSessions: originalPendingSessions,
                count: originalCount,
              ),
              errormessage: failure.message,
            ),
          );
        },
        (acceptSessionData) {
          emit(
            state.copyWith(
              acceptsessionState: CubitStates.success,
              acceptSessionData: acceptSessionData,
            ),
          );
          if (acceptSessionData.advisorStatus == "approved") {
            AcceptOrDeclneSessionEventBus.instance.notifyacceptSession(
              acceptSessionData,
            );
          }
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          acceptsessionState: CubitStates.failure,
          pendingSessionData: state.pendingSessionData?.copyWith(
            pendingSessions: originalPendingSessions,
            count: originalCount,
          ),
          errormessage: e.toString(),
        ),
      );
    }
  }

  void resetCountHelper() {
    if (state.pendingSessionData == null) return;

    emit(
      state.copyWith(
        pendingSessionData: state.pendingSessionData!.copyWith(count: 0),
      ),
    );
  }
}
