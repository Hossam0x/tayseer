import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/regard_request_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/user_chat_room_model.dart';
import 'package:tayseer/my_import.dart';

class UserChatRepo {
  final ApiService _apiService;

  UserChatRepo(this._apiService);

  Future<Either<Failure, UserChatRoomsResponse>> getUserChatRooms() async {
    try {
      final response = await _apiService.get(
        endPoint: '/new-chat/rooms',
        query: {'type': 'user-user'},
      );
      if (response['success'] == true) {
        return Right(UserChatRoomsResponse.fromJson(response));
      }
      return Left(ServerFailure(response['message'] ?? 'فشل جلب المحادثات'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, UserChatRoomsResponse>> getMatchingChatRooms({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: ApiEndPoint.userChatMatchingList,
        query: {'page': page, 'limit': limit},
      );
      if (response['success'] == true) {
        return Right(UserChatRoomsResponse.fromJson(response));
      }
      return Left(ServerFailure(response['message'] ?? 'فشل جلب المطابقات'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<RegardRequestModel>>> getRegardRequests() async {
    try {
      final response = await _apiService.get(
        endPoint: ApiEndPoint.userChatRegardRequests,
        query: {'page': 1, 'limit': 10},
      );
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final list = data['data'] as List? ?? [];
        return Right(
          list
              .map(
                (e) => RegardRequestModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        );
      }
      return Left(ServerFailure(response['message'] ?? 'فشل جلب الطلبات'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, String?>> acceptRegardRequest(String requestId) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.userChatAcceptRegard,
        data: {'regardRequestId': requestId},
      );
      if (response['success'] == true) {
        final chatRoomId = response['data']?['chatRoomId']?.toString();
        return Right(chatRoomId);
      }
      return Left(ServerFailure(response['message'] ?? 'فشل قبول الطلب'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> rejectRegardRequest(String requestId) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.userChatRejectRegard,
        data: {'regardRequestId': requestId},
      );
      if (response['success'] == true) return const Right(null);
      return Left(ServerFailure(response['message'] ?? 'فشل رفض الطلب'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> activateMatchingRoom(String chatRoomId) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.userChatRoomState,
        data: {'chatRoomId': chatRoomId, 'action': 'activate'},
      );
      if (response['success'] == true) return const Right(null);
      return Left(ServerFailure(response['message'] ?? 'فشل تفعيل المحادثة'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
