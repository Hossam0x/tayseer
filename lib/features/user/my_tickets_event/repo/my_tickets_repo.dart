import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/my_tickets_event/model/booking_event.dart';
import 'package:tayseer/features/user/my_tickets_event/model/reservation_details.dart';
import 'package:tayseer/my_import.dart';

abstract class MyTicketsRepo {
  Future<Either<Failure, List<BookingEvent>>> getMyReservations();

  Future<Either<Failure, ReservationDetails>> getReservationDetails(
    String id,
  );
}
