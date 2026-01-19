import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/create_session_response.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/get_available_day.dart';

class AvailableSlotsState {
  CubitStates getAvailableSlotsState;

  CubitStates createSessionState;

  CubitStates rescheduleSessionState;

  AvailableSlotsResponseModel? response;
  AvailableSlotsData? data;

  SessionBookingModel? sessionBookingResponse;
  SessionData? createdSession;

  int? currentMonth;
  int? currentYear;

  List<CalendarDay> availableDays;

  List<CalendarDay> allCalendarDays;

  List<DurationOption> availableDurations;

  String? errorMessage;

  String? rescheduleSuccessMessage;

  AvailableSlotsState({
    this.getAvailableSlotsState = CubitStates.initial,
    this.createSessionState = CubitStates.initial,
    this.rescheduleSessionState = CubitStates.initial,
    this.response,
    this.data,
    this.sessionBookingResponse,
    this.createdSession,
    this.currentMonth,
    this.currentYear,
    this.availableDays = const [],
    this.allCalendarDays = const [],
    this.availableDurations = const [],
    this.errorMessage,
    this.rescheduleSuccessMessage,
  });

  AvailableSlotsState copyWith({
    CubitStates? getAvailableSlotsState,
    CubitStates? createSessionState,
    CubitStates? rescheduleSessionState,
    AvailableSlotsResponseModel? response,
    AvailableSlotsData? data,
    SessionBookingModel? sessionBookingResponse,
    SessionData? createdSession,
    int? currentMonth,
    int? currentYear,
    List<CalendarDay>? availableDays,
    List<CalendarDay>? allCalendarDays,
    List<DurationOption>? availableDurations,
    String? errorMessage,
    String? rescheduleSuccessMessage,
  }) {
    return AvailableSlotsState(
      getAvailableSlotsState:
          getAvailableSlotsState ?? this.getAvailableSlotsState,
      createSessionState: createSessionState ?? this.createSessionState,
      rescheduleSessionState:
          rescheduleSessionState ?? this.rescheduleSessionState,
      response: response ?? this.response,
      data: data ?? this.data,
      sessionBookingResponse:
          sessionBookingResponse ?? this.sessionBookingResponse,
      createdSession: createdSession ?? this.createdSession,
      currentMonth: currentMonth ?? this.currentMonth,
      currentYear: currentYear ?? this.currentYear,
      availableDays: availableDays ?? this.availableDays,
      allCalendarDays: allCalendarDays ?? this.allCalendarDays,
      availableDurations: availableDurations ?? this.availableDurations,
      errorMessage: errorMessage ?? this.errorMessage,
      rescheduleSuccessMessage:
          rescheduleSuccessMessage ?? this.rescheduleSuccessMessage,
    );
  }
}
