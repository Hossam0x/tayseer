import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/get_available_day.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/create_session/create_session_state.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/create_session/rescedule_session_event_bus.dart';

class AvailableSlotsCubit extends Cubit<AvailableSlotsState> {
  final MySpaceRepo mySpaceRepo;

  AvailableSlotsCubit(this.mySpaceRepo) : super(AvailableSlotsState());

  String? _currentAdvisorId;

  Future<void> getAvailableSlots(String advisorId, {int? month}) async {
    _currentAdvisorId = advisorId;
    emit(state.copyWith(getAvailableSlotsState: CubitStates.loading));

    CubitStates.printState(
      stateName: 'AvailableSlotsCubit - getAvailableSlots',
      state: CubitStates.loading,
    );

    final result = await mySpaceRepo.getAvailableSlots(advisorId, month: month);

    result.fold(
      (failure) {
        CubitStates.printState(
          stateName: 'AvailableSlotsCubit - getAvailableSlots',
          state: CubitStates.failure,
        );
        emit(
          state.copyWith(
            getAvailableSlotsState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (response) {
        CubitStates.printState(
          stateName: 'AvailableSlotsCubit - getAvailableSlots',
          state: CubitStates.success,
        );

        final availableDays = response.data.calendarDays
            .where((day) => day.isAvailable)
            .toList();

        final availableDurations = response.data.duration
            .where((d) => d.isEnabled)
            .toList();

        emit(
          state.copyWith(
            getAvailableSlotsState: CubitStates.success,
            response: response,
            data: response.data,
            currentMonth: response.data.month,
            currentYear: response.data.year,
            allCalendarDays: response.data.calendarDays,
            availableDays: availableDays,
            availableDurations: availableDurations,
          ),
        );
      },
    );
  }

  Future<void> getNextMonth() async {
    if (_currentAdvisorId == null) return;

    int nextMonth = (state.currentMonth ?? DateTime.now().month) + 1;

    if (nextMonth > 12) {
      nextMonth = 1;
    }

    await getAvailableSlots(_currentAdvisorId!, month: nextMonth);
  }

  Future<void> getPreviousMonth() async {
    if (_currentAdvisorId == null) return;

    int prevMonth = (state.currentMonth ?? DateTime.now().month) - 1;

    if (prevMonth < 1) {
      prevMonth = 12;
    }

    await getAvailableSlots(_currentAdvisorId!, month: prevMonth);
  }

  List<TimeSlot> getTimeSlotsForDay(String date, int durationMinutes) {
    if (state.data == null) return [];

    final day = state.allCalendarDays.firstWhere(
      (d) => d.date == date,
      orElse: () => CalendarDay(
        date: '',
        dayOfWeek: 0,
        isAvailable: false,
        timeSlots30: [],
        timeSlots60: [],
      ),
    );

    return day.getAvailableSlots(durationMinutes);
  }

  bool isDayAvailable(int dayNumber) {
    return state.availableDays.any((day) => day.dayNumber == dayNumber);
  }

  CalendarDay? getDayData(String date) {
    try {
      return state.allCalendarDays.firstWhere((d) => d.date == date);
    } catch (e) {
      return null;
    }
  }

  Future<void> createSession({
    required String date,
    required String advisorId,
    required String duration,
    required String time,
    required String paymentMethod,
  }) async {
    emit(state.copyWith(createSessionState: CubitStates.loading));

    CubitStates.printState(
      stateName: 'AvailableSlotsCubit - createSession',
      state: CubitStates.loading,
    );

    final result = await mySpaceRepo.createSession(
      date: date,
      advisorId: advisorId,
      duration: duration,
      time: time,
      paymentMethod: paymentMethod,
    );

    result.fold(
      (failure) {
        CubitStates.printState(
          stateName: 'AvailableSlotsCubit - createSession',
          state: CubitStates.failure,
        );
        emit(
          state.copyWith(
            createSessionState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (response) {
        CubitStates.printState(
          stateName: 'AvailableSlotsCubit - createSession',
          state: CubitStates.success,
        );
        emit(
          state.copyWith(
            createSessionState: CubitStates.success,
            sessionBookingResponse: response,
            createdSession: response.data,
          ),
        );
      },
    );
  }

  Future<void> rescheduleSession({
    required String sessionId,
    required String date,
    required String duration,
    required String time,
  }) async {
    emit(state.copyWith(rescheduleSessionState: CubitStates.loading));

    CubitStates.printState(
      stateName: 'AvailableSlotsCubit - rescheduleSession',
      state: CubitStates.loading,
    );

    final result = await mySpaceRepo.updateSession(
      sessionId: sessionId,
      date: date,
      duration: duration,
      time: time,
    );

    result.fold(
      (failure) {
        CubitStates.printState(
          stateName: 'AvailableSlotsCubit - rescheduleSession',
          state: CubitStates.failure,
        );
        emit(
          state.copyWith(
            rescheduleSessionState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (data) {
        CubitStates.printState(
          stateName: 'AvailableSlotsCubit - rescheduleSession',
          state: CubitStates.success,
        );
        emit(
          state.copyWith(
            rescheduleSessionState: CubitStates.success,
            rescheduleSuccessMessage: 'تم إعادة جدولة الجلسة بنجاح',
          ),
        );
        ResceduleSessionEventBus.instance.notifySessionRescheduled(data);
      },
    );
  }

  void resetRescheduleState() {
    emit(
      state.copyWith(
        rescheduleSessionState: CubitStates.initial,
        rescheduleSuccessMessage: null,
        errorMessage: null,
      ),
    );
  }

  void resetCreateSessionState() {
    emit(
      state.copyWith(
        createSessionState: CubitStates.initial,
        errorMessage: null,
      ),
    );
  }

  // إعادة تعيين الحالة الكاملة
  void reset() {
    _currentAdvisorId = null;
    emit(AvailableSlotsState());
  }
}
