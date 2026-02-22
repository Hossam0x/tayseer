import 'package:tayseer/features/user/my_tickets_event/model/booking_event.dart';
import 'package:tayseer/features/user/my_tickets_event/model/reservation_details.dart';
import 'package:tayseer/my_import.dart';

class MyTicketState {
  final CubitStates myReservationsState;
  final CubitStates reservationDetailsState;
  final List<BookingEvent>? myReservations;
  final ReservationDetails? reservationDetails;
  final String? errorMessage;

  const MyTicketState({
    this.myReservationsState = CubitStates.initial,
    this.reservationDetailsState = CubitStates.initial,
    this.myReservations = const [],
    this.reservationDetails,
    this.errorMessage,
  });

  MyTicketState copyWith({
    CubitStates? myReservationsState,
    CubitStates? reservationDetailsState,
    List<BookingEvent>? myReservations,
    ReservationDetails? reservationDetails,
    String? errorMessage,
  }) {
    return MyTicketState(
      myReservationsState: myReservationsState ?? this.myReservationsState,
      reservationDetailsState:
          reservationDetailsState ?? this.reservationDetailsState,
      myReservations: myReservations ?? this.myReservations,
      reservationDetails: reservationDetails ?? this.reservationDetails,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isMyReservationsLoading =>
      myReservationsState == CubitStates.loading;
  bool get isMyReservationsSuccess =>
      myReservationsState == CubitStates.success;
  bool get isMyReservationsFailure =>
      myReservationsState == CubitStates.failure;

  bool get isReservationDetailsLoading =>
      reservationDetailsState == CubitStates.loading;
  bool get isReservationDetailsSuccess =>
      reservationDetailsState == CubitStates.success;
  bool get isReservationDetailsFailure =>
      reservationDetailsState == CubitStates.failure;
}
