import 'package:dartz/dartz.dart';
import 'package:tayseer/features/shared/followers/data/models/follower_model.dart';
import 'package:tayseer/my_import.dart';

abstract class UserFollowingsRepository {
  Future<Either<Failure, List<FollowerModel>>> getUserFollowings({
    required String userId,
    int page = 1,
    int limit = 10,
    String? searchQuery,
  });

  Future<Either<Failure, String>> toggleFollow(String targetUserId);
}

class UserFollowingsRepositoryImpl implements UserFollowingsRepository {
  final ApiService _apiService;

  UserFollowingsRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, List<FollowerModel>>> getUserFollowings({
    required String userId,
    int page = 1,
    int limit = 10,
    String? searchQuery,
  }) async {
    try {
      final Map<String, dynamic> query = {'page': page, 'limit': limit};

      // البحث يكون بالـ param name
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query['name'] = searchQuery;
      }

      final response = await _apiService.get(
        endPoint: '/user/followings/$userId',
        query: query,
      );

      if (response['success'] == true) {
        // ⭐ التصحيح: الـ data هي List مباشرة وليست داخل Map
        final data = response['data'];

        List<dynamic> followingsList;

        if (data is List<dynamic>) {
          // الحالة: data هي List مباشرة
          followingsList = data;
        } else if (data is Map<String, dynamic>) {
          // الحالة: data هي Map تحتوي على followers/following
          followingsList =
              data['followings'] as List<dynamic>? ??
              data['following'] as List<dynamic>? ??
              [];
        } else {
          followingsList = [];
        }

        final followings = followingsList
            .map(
              (item) => FollowerModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
        return Right(followings);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب المتابَعين'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e, stackTrace) {
      print('Error in getUserFollowings: $e');
      print('Stack trace: $stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> toggleFollow(String targetUserId) async {
    try {
      final response = await _apiService.post(
        endPoint: '/advisor/toggle-follow/$targetUserId',
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
