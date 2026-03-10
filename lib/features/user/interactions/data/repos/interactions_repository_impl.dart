import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/user/interactions/data/Model/history_response_model.dart';
import 'package:tayseer/features/user/interactions/data/Model/exploration_response_model.dart';
import 'package:tayseer/features/user/interactions/data/repos/interactions_repository.dart';

class InteractionsRepositoryImpl implements InteractionsRepository {
  final ApiService apiService;

  InteractionsRepositoryImpl(this.apiService);

  // ═══════════════════════════════════════════════════════════════════
  // EXPLORATION
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, ExplorationResponseModel>> fetchExplorationUsers({
    required String category,
    required int page,
  }) async {
    try {
      // 1. Main exploration call
      final response = await apiService.get(
        endPoint: '/user/discovered-users',
        query: {'page': page.toString(), 'limit': '10'},
      );

      ExplorationResponseModel explorationResponse =
          ExplorationResponseModel.fromJson(response);

      // 2. Recently joined → "منضم حديثاً"
      try {
        final recentlyJoinedResponse = await apiService.get(
          endPoint: '/user/recently-joined-users',
        );
        explorationResponse =
            explorationResponse.withRecentlyJoined(recentlyJoinedResponse);
      } catch (_) {}

      // 3. Users liked me → "الإعجابات"
      try {
        final likedMeResponse = await apiService.get(
          endPoint: '/user/users-liked-me',
        );
        explorationResponse =
            explorationResponse.withLikedMe(likedMeResponse);
      } catch (_) {}

      // 4. Users to send regards to → "ارسل تحية"
      try {
        final sendRegardsResponse = await apiService.get(
          endPoint: '/user/users-to-send-regards-to',
        );
        explorationResponse =
            explorationResponse.withSendRegards(sendRegardsResponse);
      } catch (_) {}

      return Right(explorationResponse);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // HISTORY
  // ═══════════════════════════════════════════════════════════════════
  static const int _pageSize = 6;

  @override
  Future<Either<Failure, HistoryResponseModel>> fetchHistoryUsers({
    required String filter,
    required int page,
  }) async {
    try {
      final response = await apiService.get(
        endPoint: '/user/user-interactions',
        query: {
          'page': page.toString(),
          'limit': _pageSize.toString(),
          'type': _mapFilterToApiType(filter),
        },
      );

      final historyResponse = HistoryResponseModel.fromJson(response);
      return Right(historyResponse);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  String _mapFilterToApiType(String filterKey) {
    switch (filterKey) {
      case 'favorites':
        return 'favorites';
      case 'liked_you':
        return 'likes';
      case 'met_them':
        return 'encountered';
      case 'sent_compliment':
        return 'regards';
      case 'liked_me':
        return 'likedMe';
      default:
        return 'likes';
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, String>> toggleFavorite({
    required String userId,
    required bool isAdd,
  }) async {
    try {
      if (isAdd) {
        final response = await apiService.post(
          endPoint: '/user/user-interaction',
          data: {
            'personInteractedWith': userId,
            'interactionType': 'favorite',
          },
        );
        final message = response['message'] ?? 'تمت الإضافة للمفضلة بنجاح';
        return Right(message);
      } else {
        final response = await apiService.post(
          endPoint: '/user/user-interaction?action=remove',
          data: {
            'personInteractedWith': userId,
            'interactionType': 'favorite',
          },
        );
        final message = response['message'] ?? 'تمت الإزالة من المفضلة بنجاح';
        return Right(message);
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendCompliment({
    required String personId,
    String? text,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: '/user/send-regards',
        data: {
          'personInteractedWith': personId,
          if (text != null) 'text': text,
        },
      );

      if (response['success'] == true) {
        return Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل ارسال التحيه'));
      }
    } on DioException catch (e) {
      return Future.value(Left(ServerFailure.fromDioError(e)));
    } catch (e) {
      return Future.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, String>> likeUser({required String userId}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      return const Right('تم الإعجاب بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ: ${e.toString()}'));
    }
  }
}