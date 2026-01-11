import 'package:dartz/dartz.dart';
import 'package:tayseer/core/functions/upload_imageandvideo_to_api.dart';
import 'package:tayseer/features/advisor/event/model/my_event_model.dart';
import 'package:tayseer/features/advisor/event/repo/event_repo.dart';
import 'package:tayseer/my_import.dart';

class EventRepoImpl implements EventRepo {
  EventRepoImpl({required this.apiService});
  ApiService apiService;
  @override
  Future<Either<Failure, List<EventModel>>> getAdvisorEvents() async {
    try {
      final response = await apiService.get(
        endPoint: '/event/getAdvisorEvents',
      );
      final eventsJson = response['data'] as List;

      List<EventModel> results = eventsJson
          .map((event) => EventModel.fromJson(event))
          .toList();

      debugPrint('Events fetched: $results');

      return Right(results);
    } on DioException catch (error) {
      return left(error.response?.data['message']);
    } catch (e) {
      debugPrint('Error fetching events: $e');
      return Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    }
  }

  @override
  Future<Either<Failure, List<EventModel>>> getAllEvents(
    String? location,
  ) async {
    try {
      final response = await apiService.get(
        endPoint: '/event/getAllEvents',
        query: {"location": location},
      );
      final eventsJson = response['data'] as List;

      List<EventModel> results = eventsJson
          .map((event) => EventModel.fromJson(event))
          .toList();

      debugPrint('All Events fetched: $results');

      return Right(results);
    } on DioException catch (error) {
      return left(error.response?.data['message']);
    } catch (e) {
      debugPrint('Error fetching events: $e');
      return Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    }
  }

  @override
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
  }) async {
    try {
      final response = await apiService.post(
        isFromData: true,
        endPoint: '/event/createEvent',
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
          if (video != null) 'video': await uploadVideoToApi(video),
        },
        isAuth: true,
      );

      final success = response['success'] ?? false;
      debugPrint('success $success');

      if (success) {
        return right(null);
      } else {
        final message = response['message'] ?? 'فشل ارسال الاجابه';
        debugPrint('message $message');

        return left(ServerFailure(message));
      }
    } on DioException catch (error) {
      debugPrint('DioException error $error');
      return left(
        ServerFailure(
          error.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر',
        ),
      );
    } catch (error) {
      debugPrint(' error $error');
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent({required String id}) async {
    try {
      final response = await apiService.delete(
        endPoint: '/event/deleteEvent/$id',
      );

      final success = response['success'] ?? false;

      if (success) return right(null);

      return left(ServerFailure(response['message'] ?? 'فشل حذف الحدث'));
    } on DioException catch (error) {
      return left(
        ServerFailure(
          error.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر',
        ),
      );
    } catch (e) {
      debugPrint('Error deleting event: $e');
      return Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    }
  }
}
