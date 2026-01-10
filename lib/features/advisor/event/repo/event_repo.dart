import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/features/advisor/event/model/my_event_model.dart';

abstract class EventRepo {
  Future<Either<Failure, List<EventModel>>> getAdvisorEvents();
  Future<Either<Failure, List<EventModel>>> getAllEvents();
  Future<Either<Failure, void>> createEvent({
    required String title,
    required String description,
    required String date,
    required String startTime,
    required String priceAfterDiscount,
    required String priceBeforeDiscount,
    required String duration,
    required String latitude,
    required String longitude,
    required List<XFile> images,
    XFile? video,
    required String numberOfAttendees,
    required String location,
  });
  Future<Either<Failure, void>> deleteEvent({
    required String id,
  });
}
