import 'package:dartz/dartz.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/user/user_advisor_profile/data/models/user_advisor_profile_model.dart';
import 'package:tayseer/my_import.dart';

abstract class UserAdvisorProfileRepository {
  Future<Either<Failure, UserAdvisorProfileModel>> getUserProfile(
    String advisorId,
  );
  Future<Either<Failure, List<PostModel>>> fetchUserPosts({
    required String advisorId,
    required int page,
  });
  Future<Either<Failure, String>> toggleFollowUser(String advisorId);
  Future<void> reactToPost({
    required String postId,
    required ReactionType? reactionType,
    required bool isRemove,
  });
  Future<Either<Failure, String>> sharePost({
    required String postId,
    required String action,
  });
}

// features/advisor/user_profile/data/repositories/user_profile_repository_impl.dart
class UserAdvisorProfileRepositoryImpl implements UserAdvisorProfileRepository {
  final ApiService _apiService;

  UserAdvisorProfileRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, UserAdvisorProfileModel>> getUserProfile(
    String advisorId,
  ) async {
    try {
      final response = await _apiService.get(
        endPoint: '/advisor/getProfile',
        query: {'advisorId': advisorId},
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;

        // ⭐ تنظيف نص سنوات الخبرة
        String? yearsExpString = data['yearsOfExperience']?.toString();
        if (yearsExpString != null && yearsExpString.isNotEmpty) {
          yearsExpString = yearsExpString.replaceAll(" من الخبرة", "");
        }

        // ⭐ إنشاء بيانات معدلة
        final profileData = Map<String, dynamic>.from(data);
        profileData['yearsOfExperience'] = yearsExpString;

        final profile = UserAdvisorProfileModel.fromJson(profileData);
        return Right(profile);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب البروفايل'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostModel>>> fetchUserPosts({
    required String advisorId,
    required int page,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/posts/all-for-advisor',
        query: {'page': page, 'advisorId': advisorId},
      );

      if (response['success'] == true) {
        final postsList =
            (response['data']?['postsDto'] as List<dynamic>?)
                ?.map((e) => PostModel.fromJson(e))
                .toList() ??
            [];
        return Right(postsList);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب المنشورات'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> toggleFollowUser(String advisorId) async {
    try {
      final response = await _apiService.post(
        endPoint: '/advisor/toggle-follow/$advisorId',
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> reactToPost({
    required String postId,
    required ReactionType? reactionType,
    required bool isRemove,
  }) async {
    final Map<String, dynamic> requestData = {
      "postId": postId,
      "action": isRemove ? "remove" : "add",
    };
    if (!isRemove) {
      requestData["type"] = reactionType!.name;
    }
    await _apiService.post(endPoint: ApiEndPoint.like, data: requestData);
  }

  @override
  Future<Either<Failure, String>> sharePost({
    required String postId,
    required String action,
  }) async {
    try {
      final Map<String, dynamic> requestData = {"postId": postId};
      var response = await _apiService.post(
        endPoint: "${ApiEndPoint.share}?action=$action",
        data: requestData,
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
