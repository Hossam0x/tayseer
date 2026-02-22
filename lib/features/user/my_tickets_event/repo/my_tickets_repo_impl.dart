import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/my_tickets_event/model/booking_event.dart';
import 'package:tayseer/features/user/my_tickets_event/model/reservation_details.dart';
import 'package:tayseer/features/user/my_tickets_event/repo/my_tickets_repo.dart';
import 'package:tayseer/my_import.dart';

class MyTicketsRepoImpl implements MyTicketsRepo {
  MyTicketsRepoImpl({required this.apiService});
  final ApiService apiService;

  @override
  Future<Either<Failure, List<BookingEvent>>> getMyReservations() async {
    try {
      final response = await apiService.get(
        endPoint: '/event-reservation/my-reservations',
      );

      final data = response['data'];

      if (data is List) {
        final results = data
            .map((e) => BookingEvent.fromJson(e as Map<String, dynamic>))
            .toList();

        return Right(results);
      }

      return Left(ServerFailure('بيانات غير متوقعة من الخادم'));
    } on DioException catch (error) {
      return Left(
        ServerFailure(
          error.response?.data?['message'] ?? 'خطأ في الاتصال بالسيرفر',
        ),
      );
    } catch (e) {
      debugPrint('Error getMyReservations: $e');
      return Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    }
  }

  @override
  Future<Either<Failure, ReservationDetails>> getReservationDetails(
    String id,
  ) async {
    try {
      final response = await apiService.get(
        endPoint: '/event-reservation/reserve-details/$id',
      );

      final data = response['data'];

      if (data is Map<String, dynamic>) {
        return Right(ReservationDetails.fromJson(data));
      }

      return Left(ServerFailure('بيانات غير متوقعة من الخادم'));
    } on DioException catch (error) {
      return Left(
        ServerFailure(
          error.response?.data?['message'] ?? 'خطأ في الاتصال بالسيرفر',
        ),
      );
    } catch (e) {
      debugPrint('Error getReservationDetails: $e');
      return Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    }
  }
}
