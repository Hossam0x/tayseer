import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../model/event_detail_model.dart';
import 'event_detail_repository.dart';

class EventDetailRepositoryImpl implements EventDetailRepository {
  EventDetailRepositoryImpl(this._apiService);
  final ApiService _apiService;
  @override
  Future<Either<Failure, EventDetailModel>> getEventDetails({
    required String id,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/event/getEventDetails/$id',
      );
      final eventsJson = response['data'];
      EventDetailModel results = EventDetailModel.fromJson(eventsJson);

      debugPrint('get Event Details: $results');

      return Right(results);
    } on DioException catch (error) {
      return left(error.response?.data['message']);
    } catch (e) {
      debugPrint('Error fetching get Event Details: $e');
      return Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    }
  }

  @override
  Future<Either<Failure, void>> updateEvent({
    required String id,
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
    required String numberOfAttendees,
    required String location,
  }) async {
    try {
      final response = await _apiService.patch(
        isFromData: true,
        endPoint: '/event/updateEvent/$id',
        data: {
          'title': title,
          'description': description,
          'date': date,
          'startTime': startTime,
          'priceAfterDiscount': priceAfterDiscount,
          'priceBeforeDiscount': priceBeforeDiscount,
          'duration': duration,
          'latitude': latitude,
          'longitude': longitude,
          'numberOfAttendees': numberOfAttendees,
          'location': location,
          'images': await Future.wait(
            images.map(
              (image) async => await MultipartFile.fromFile(
                image.path,
                filename: image.name,
              ),
            ),
          ),
        },
      );

      final success = response['success'] ?? false;

      if (success) return right(null);

      return left(ServerFailure(response['message'] ?? 'فشل تحديث الحدث'));
    } on DioException catch (error) {
      return left(
        ServerFailure(
          error.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر',
        ),
      );
    } catch (e) {
      debugPrint('Error updating event: $e');
      return Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    }
  }
}
