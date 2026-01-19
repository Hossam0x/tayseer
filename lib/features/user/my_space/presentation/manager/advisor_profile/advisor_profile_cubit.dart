import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/my_space/data/model/advisorprofile/session_model.dart';
import 'package:tayseer/features/user/my_space/data/model/advisorprofile/time_range_model.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart'
    hide TimeRangeModel;
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/advisor_profile/advisor_profile_state.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/create_session/rescedule_session_event_bus.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/session_detailes/cancel_session_event_bus.dart';

class AdvisorProfileCubit extends Cubit<AdvisorProfileState> {
  final MySpaceRepo mySpaceRepo;
  StreamSubscription<String>? _cancelSubscription;
  StreamSubscription<SessionDetailsDataResponse>? _rescheduleSubscription;

  AdvisorProfileCubit(this.mySpaceRepo) : super(AdvisorProfileState()) {
    _listenToSessionEvents();
    _listenToRescheduleEvents();
  }

  void _listenToSessionEvents() {
    _cancelSubscription = SessionEventService.instance.onSessionCancelled
        .listen((sessionId) => _removeSessionLocally(sessionId));
  }

  void _listenToRescheduleEvents() {
    _rescheduleSubscription = ResceduleSessionEventBus
        .instance
        .onSessionRescheduled
        .listen(_rescheduleSessionLocally);
  }

  void fetchAdvisorProfile(String userId) {
    emit(state.copyWith(getadvisorchatprofileState: CubitStates.loading));

    mySpaceRepo.getadvisorchatprofile(userId).then((either) {
      either.fold(
        (failure) {
          emit(
            state.copyWith(
              getadvisorchatprofileState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (sessionsResponse) {
          emit(
            state.copyWith(
              getadvisorchatprofileState: CubitStates.success,
              advisor: sessionsResponse.data.advisor,
              expiredSessions: sessionsResponse.data.sessionExpired,
              upcomingSessions: sessionsResponse.data.sessionNotExpired,
              allSessions: [
                ...sessionsResponse.data.sessionExpired,
                ...sessionsResponse.data.sessionNotExpired,
              ],
            ),
          );
        },
      );
    });
  }

  void _removeSessionLocally(String sessionId) {
    if (isClosed || state.allSessions.isEmpty) return;

    emit(
      state.copyWith(
        upcomingSessions: state.upcomingSessions
            .where((session) => session.sessionId != sessionId)
            .toList(),
        expiredSessions: state.expiredSessions
            .where((session) => session.sessionId != sessionId)
            .toList(),
        allSessions: state.allSessions
            .where((session) => session.sessionId != sessionId)
            .toList(),
      ),
    );
  }

  void _rescheduleSessionLocally(SessionDetailsDataResponse sessionData) {
    if (isClosed || state.allSessions.isEmpty) return;

    final allSessionIndex = state.allSessions.indexWhere(
      (session) => session.sessionId == sessionData.sessionId,
    );

    if (allSessionIndex == -1) return;

    final newTimeRange = TimeRangeModel(
      from: sessionData.timeRange.from,
      to: sessionData.timeRange.to,
    );

    final updatedAllSessions = List<SessionModel>.from(state.allSessions);
    updatedAllSessions[allSessionIndex] = updatedAllSessions[allSessionIndex]
        .copyWith(
          date: sessionData.date,
          timeRange: newTimeRange,
          status: sessionData.status,
        );

    final updatedUpcoming = List<SessionModel>.from(state.upcomingSessions);
    final upcomingIndex = updatedUpcoming.indexWhere(
      (session) => session.sessionId == sessionData.sessionId,
    );
    if (upcomingIndex != -1) {
      updatedUpcoming[upcomingIndex] = updatedUpcoming[upcomingIndex].copyWith(
        date: sessionData.date,
        timeRange: newTimeRange,
        status: sessionData.status,
      );
    }

    final updatedExpired = List<SessionModel>.from(state.expiredSessions);
    final expiredIndex = updatedExpired.indexWhere(
      (session) => session.sessionId == sessionData.sessionId,
    );
    if (expiredIndex != -1) {
      updatedExpired[expiredIndex] = updatedExpired[expiredIndex].copyWith(
        date: sessionData.date,
        timeRange: newTimeRange,
        status: sessionData.status,
      );
    }

    emit(
      state.copyWith(
        allSessions: updatedAllSessions,
        upcomingSessions: updatedUpcoming,
        expiredSessions: updatedExpired,
      ),
    );
  }

  @override
  Future<void> close() {
    _cancelSubscription?.cancel();
    _rescheduleSubscription?.cancel();
    return super.close();
  }
}
