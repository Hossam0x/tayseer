import 'package:dartz/dartz.dart';
import 'package:tayseer/features/shared/followers/data/models/follower_model.dart';
import 'package:tayseer/my_import.dart';

abstract class FollowersRepository {
  Future<Either<Failure, List<FollowerModel>>> getFollowers({
    required String userId,
    int page = 1,
    int limit = 10,
    String? searchQuery,
  });

  Future<Either<Failure, List<FollowerModel>>> getFollowing({
    required String userId,
    int page = 1,
    int limit = 10,
    String? searchQuery,
  });

  Future<Either<Failure, String>> toggleFollow(
    String targetUserId, {
    required bool isCurrentlyFollowing,
  });
}

class FollowersRepositoryImpl implements FollowersRepository {
  final ApiService _apiService;

  FollowersRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, List<FollowerModel>>> getFollowers({
    required String userId,
    int page = 1,
    int limit = 10,
    String? searchQuery,
  }) async {
    try {
      final Map<String, dynamic> query = {'page': page, 'limit': limit};

      // ⭐ تعديل: البحث يكون بالـ param name وليس search
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query['name'] = searchQuery; // ⭐ تغيير من 'search' إلى 'name'
      }

      final response = await _apiService.get(
        endPoint: '/advisor/followers/$userId',
        query: query,
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;

        final followersList = data['followers'] as List<dynamic>? ?? [];

        final followers = followersList
            .map(
              (item) => FollowerModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
        return Right(followers);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب المتابعين'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e, stackTrace) {
      print('Error in getFollowers: $e');
      print('Stack trace: $stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FollowerModel>>> getFollowing({
    required String userId,
    int page = 1,
    int limit = 10,
    String? searchQuery,
  }) async {
    try {
      final Map<String, dynamic> query = {'page': page, 'limit': limit};

      // ⭐ تعديل: البحث يكون بالـ param name وليس search
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query['name'] = searchQuery; // ⭐ تغيير من 'search' إلى 'name'
      }

      final response = await _apiService.get(
        endPoint: '/advisor/following/$userId',
        query: query,
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;

        final followingList = data['following'] as List<dynamic>? ?? [];

        final following = followingList
            .map(
              (item) => FollowerModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
        return Right(following);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب المتابَعين'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e, stackTrace) {
      print('Error in getFollowing: $e');
      print('Stack trace: $stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> toggleFollow(
    String targetUserId, {
    required bool isCurrentlyFollowing,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: '/advisor/toggle-follow/$targetUserId',
        query: {'action': isCurrentlyFollowing ? 'remove' : 'add'},
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
