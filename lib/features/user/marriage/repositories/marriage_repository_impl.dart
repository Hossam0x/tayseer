import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/interactions/data/Model/history_response_model.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';
import 'package:tayseer/features/user/marriage/repositories/marriage_repository.dart';
import 'package:tayseer/my_import.dart';

class MarriageRepositoryImpl implements MarriageRepository {
  final ApiService _apiService;

  MarriageRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, UsersMarriageResponse>> getMarriageProfile(
    String? page, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        if (filters != null && filters.isNotEmpty) ...filters,
      };

      final response = await _apiService.get(
        endPoint: '/user/users-for-marry',
        query: query,
      );

      if (response['success'] == true) {
        return Right(UsersMarriageResponse.fromJson(response));
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب الملف'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> userInteraction({
    required String personId,
    required String interactionType,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: '/user/user-interaction',
        data: {
          'personInteractedWith': personId,
          'interactionType': interactionType,
        },
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل التفاعل مع المستخدم'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendRegard({
    required String personId,
    String? text,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: '/user/send-regards',
        data: {
          'personInteractedWith': personId,
          if (text != null) 'text': text,
        },
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل ارسال التحيه'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite({
    required String userId,
    required bool isAdd,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: '/user/user-interaction',
        query: isAdd ? null : {'action': 'remove'},
        data: {'personInteractedWith': userId, 'interactionType': 'favorite'},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل تعديل المفضلة'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFavoriteIds() async {
    try {
      final response = await _apiService.get(
        endPoint: '/user/user-interaction',
        query: {'interactionType': 'favorite'},
      );
      if (response['success'] == true) {
        final List data = response['data'] ?? [];
        final ids = data
            .map((item) => item['personInteractedWith']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
        return Right(ids);
      } else {
        return Left(ServerFailure(response['message'] ?? ''));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> blockUser({required String personId}) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.blockuser,
        data: {'blockedId': personId},
      );
      if (response['success'] == true) {
        return Right(response['message'] ?? 'تم الحظر بنجاح');
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل الحظر'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserItem>> getProfileById(String userId) async {
    try {
      final response = await _apiService.get(
        endPoint: '/user/one-user-for-marry/$userId',
      );
      if (response['success'] == true) {
        final data = response['data'];
        final userData = data['userData'];
        final allowInteractions = data['allowInteractions'] as bool? ?? true;

        final userItem = UserItem.fromJson({
          ...userData,
          'allowInteractions': allowInteractions,
        });
        return Right(userItem);
      } else {
        return Left(ServerFailure(response['message'] ?? ''));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationCountModel>>
      getInteractionNotificationCount() async {
    try {
      final response = await _apiService.get(
        endPoint: '/user/interactions-notification-count',
      );
      if (response['success'] == true) {
        return Right(NotificationCountModel.fromJson(response));
      } else {
        return Left(ServerFailure(response['message'] ?? ''));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setUserLocation({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _apiService.patch(
        endPoint: '/user/set-location',
        data: {'lat': lat, 'lng': lng},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل تحديث الموقع'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetAllNotificationCounts() async {
    try {
      await Future.wait([
        _apiService.patch(endPoint: '/user/reset-likes-notification-count'),
        _apiService.patch(endPoint: '/user/reset-favorites-notification-count'),
        _apiService.patch(endPoint: '/user/reset-regards-notification-count'),
      ]);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resetLikesNotificationCount() async {
    try {
      await _apiService.patch(
        endPoint: '/user/reset-likes-notification-count',
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resetFavoritesNotificationCount() async {
    try {
      await _apiService.patch(
        endPoint: '/user/reset-favorites-notification-count',
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resetRegardsNotificationCount() async {
    try {
      await _apiService.patch(
        endPoint: '/user/reset-regards-notification-count',
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ: ${e.toString()}'));
    }
  }
}