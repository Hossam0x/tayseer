import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/advisor/notification/data/models/notification_model.dart';

class NotificationRepo {
  final ApiService apiService;

  NotificationRepo({required this.apiService});

  Future<Either<Failure, NotificationsModel>> getAllNotification(
      int page
      ) async {
    try {
      final response = await apiService.get(endPoint: "/notification/me?page=$page");
      return Right(NotificationsModel.fromJson(response));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}