import 'dart:async';
import 'dart:developer';

import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/create_session/rescedule_session_event_bus.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/session_detailes/cancel_session_event_bus.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/session_detailes/session_detailes_state.dart';
import 'package:tayseer/my_import.dart';

class SesionDetailesCubit extends Cubit<SessionDetailesState> {
  final MySpaceRepo mySpaceRepo;
  StreamSubscription<SessionDetailsDataResponse>? _rescheduleController;

  SesionDetailesCubit(this.mySpaceRepo) : super(SessionDetailesState()) {
    _listenToRescheduleEvents();
  }

  void _listenToRescheduleEvents() {
    log('SesionDetailesCubit: Listening to reschedule events');
    _rescheduleController = ResceduleSessionEventBus
        .instance
        .onSessionRescheduled
        .listen(_reschedulesessionlocally);
  }

  void _reschedulesessionlocally(SessionDetailsDataResponse sessionData) {
    log(
      'SesionDetailesCubit: Received reschedule event for sessionId: ${sessionData.sessionId}',
    );

    if (isClosed) {
      log('SesionDetailesCubit: Cubit is closed, skipping emit');
      return;
    }

    if (state.sessionDetailsData == null) {
      log('SesionDetailesCubit: No current session data, skipping');
      return;
    }

    final currentSessionId = state.sessionDetailsData!.sessionId;
    if (currentSessionId != sessionData.sessionId) {
      log(
        'SesionDetailesCubit: Session ID mismatch - current: $currentSessionId, received: ${sessionData.sessionId}',
      );
      return;
    }

    final updatedSession = state.sessionDetailsData!.copyWith(
      date: sessionData.date,
      timeRange: sessionData.timeRange,
      pricing: sessionData.pricing,
      status: sessionData.status,
      duration: sessionData.duration,
    );

    log('SesionDetailesCubit: Emitting updated session');
    log('SesionDetailesCubit: New date: ${updatedSession.date}');
    log(
      'SesionDetailesCubit: New time: ${updatedSession.timeRange.from} - ${updatedSession.timeRange.to}',
    );
    log('SesionDetailesCubit: New duration: ${updatedSession.duration}');

    emit(state.copyWith(sessionDetailsData: updatedSession));
  }

  Future<void> getSessionDetailes(String sessionId) async {
    emit(state.copyWith(getSessionDetailesState: CubitStates.loading));

    final result = await mySpaceRepo.getSessionDetails(sessionId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            getSessionDetailesState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (sessionDetailsData) {
        emit(
          state.copyWith(
            getSessionDetailesState: CubitStates.success,
            sessionDetailsData: sessionDetailsData.data,
          ),
        );
      },
    );
  }

  Future<void> cancelSession(String sessionId) async {
    emit(state.copyWith(cancelSession: CubitStates.loading));

    final result = await mySpaceRepo.cancelSession(sessionId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            cancelSession: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(cancelSession: CubitStates.success));
        SessionEventService.instance.notifySessionCancelled(sessionId);
      },
    );
  }

  @override
  Future<void> close() {
    log('SesionDetailesCubit: Closing and cancelling subscription');
    _rescheduleController?.cancel();
    return super.close();
  }
}
