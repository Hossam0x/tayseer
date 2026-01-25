import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/my_space/data/model/advisorprofile/session_response_model.dart';

import 'package:tayseer/features/user/my_space/data/model/advisor_chat_model.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/create_session_response.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/get_available_day.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/discount_model.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';
import 'package:tayseer/my_import.dart';

class MySpaceRepo {
  final ApiService apiService;
  MySpaceRepo(this.apiService);

  Future<Either<Failure, AdvisorChatModel>> getadvisorchat() async {
    try {
      final response = await apiService.get(
        endPoint: ApiEndPoint.advisorUserChat,
      );
      return Right(AdvisorChatModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SessionsResponseModel>> getadvisorchatprofile(
    String userId,
  ) async {
    try {
      final response = await apiService.get(
        endPoint: ApiEndPoint.advisorChatProfile(userId),
      );
      return Right(SessionsResponseModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SessionDetailsModelResponse>> getSessionDetails(
    String sessionId,
  ) async {
    try {
      final response = await apiService.get(
        endPoint: ApiEndPoint.sessionDetails(sessionId),
      );
      return Right(SessionDetailsModelResponse.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> cancelSession(String sessionId) async {
    try {
      final response = await apiService.patch(
        endPoint: ApiEndPoint.cancelSession(sessionId),
      );

      if (response['success'] == true) {
        return Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'Unknown error'));
      }
    } on DioError catch (e) {
      // امسك رسالة الخطأ من السيرفر
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'] ?? 'Unknown server error';
        return Left(ServerFailure(message));
      } else {
        return Left(ServerFailure(e.message!));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, AvailableSlotsResponseModel>> getAvailableSlots(
    String addvisorId,
  ) async {
    try {
      final response = await apiService.get(
        endPoint: ApiEndPoint.getValidDaysAndHours(
          addvisorId,
          DateTime.now().month,
        ),
      );
      return Right(AvailableSlotsResponseModel.fromJson(response));
    } on DioError catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'] ?? 'Unknown server error';
        return Left(ServerFailure(message));
      } else {
        return Left(ServerFailure(e.message ?? 'Connection error'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SessionBookingModel>> createSession({
    required String date,
    required String advisorId,
    required String duration,
    required String time,
    required String paymentMethod,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.createSession,
        data: {
          'date': date,
          'advisorId': advisorId,
          'duration': duration,
          'time': time,
          'paymentMethod': paymentMethod,
        },
      );
      return Right(SessionBookingModel.fromJson(response));
    } on DioError catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'] ?? 'Unknown server error';
        return Left(ServerFailure(message));
      } else {
        return Left(ServerFailure(e.message ?? 'Connection error'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, DiscountResponseModel>> validateDiscountCode(
    String code,
  ) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.discountcodeValidate,
        data: {'code': code},
      );
      return Right(DiscountResponseModel.fromJson(response));
    } on DioError catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'] ?? 'كود الخصم غير صحيح';
        return Left(ServerFailure(message));
      } else {
        return Left(ServerFailure(e.message ?? 'Connection error'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> paySession({
    required String sessionId,
    String? discountCode,
  }) async {
    try {
      final Map<String, dynamic> data = {'sessionId': sessionId};

      // إضافة كود الخصم فقط لو موجود
      if (discountCode != null && discountCode.isNotEmpty) {
        data['discountCode'] = discountCode;
      }

      final response = await apiService.patch(
        endPoint: ApiEndPoint.paysession,
        data: data,
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل في عملية الدفع'));
      }
    } on DioError catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'] ?? 'فشل في عملية الدفع';
        return Left(ServerFailure(message));
      } else {
        return Left(ServerFailure(e.message ?? 'Connection error'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> rateAdvisor({
    required int rating,
    required String review,
    required String sessionId,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.rateadvisor,
        data: {'rating': rating, 'review': review, 'sessionId': sessionId},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل في إرسال التقييم'),
        );
      }
    } on DioError catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'] ?? 'فشل في إرسال التقييم';
        return Left(ServerFailure(message));
      } else {
        return Left(ServerFailure(e.message ?? 'Connection error'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SessionDetailsDataResponse>> updateSession({
    required String sessionId,
    required String date,
    required String duration,
    required String time,
  }) async {
    try {
      final response = await apiService.patch(
        endPoint: ApiEndPoint.updatesession(sessionId),
        data: {'date': date, 'duration': duration, 'time': time},
      );

      if (response['success'] == true) {
        return Right(SessionDetailsDataResponse.fromJson(response['data']));
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل في تحديث الجلسة'),
        );
      }
    } on DioError catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'] ?? 'فشل في تحديث الجلسة';
        return Left(ServerFailure(message));
      } else {
        return Left(ServerFailure(e.message ?? 'Connection error'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
