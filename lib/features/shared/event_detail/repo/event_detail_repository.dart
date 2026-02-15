import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../model/event_detail_model.dart';

abstract class EventDetailRepository {
  /// Fetch event details by id
  Future<Either<Failure, EventDetailModel>> getEventDetails({
    required String id,
  });

  Future<Either<Failure, void>> updateEvent({
    required String id,
    required String title,
    required String description,
    required String date,
    required String startTime,
    required String priceAfterDiscount,
    required String priceBeforeDiscount,
    required String duration,
    required List<XFile> images,
    required String numberOfAttendees,
    required String latitude,
    required String longitude,
    required String location,
  });
}
