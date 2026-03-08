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
  Future<Either<Failure, String>> blockUser(String advisorId);
  Future<Either<Failure, String>> savedPost({
    required String postId,
    required bool isRemove,
  });
  Future<Either<Failure, String>> deletePost({required String postId});
  void hidePost({required String postId, required bool isHide});
  Future<Either<Failure, String>> archivePost({required String postId});
  Future<Either<Failure, String>> unblockUser(String advisorId);
  Future<Either<Failure, String>> reportUser({
    required String reportedId,
    required String reason,
    required String reasonDetails,
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
        endPoint: '/advisor/getProfile/$advisorId',
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;

        // ⭐ إضافة الـ ID إلى البيانات إذا لم يكن موجوداً
        if (!data.containsKey('id') && !data.containsKey('_id')) {
          data['id'] = advisorId;
        }

        // ⭐ تنظيف نص سنوات الخبرة
        String? yearsExpString = data['yearsOfExperience']?.toString();
        if (yearsExpString != null && yearsExpString.isNotEmpty) {
          yearsExpString = yearsExpString.replaceAll(" من الخبرة", "");
        }

        // ⭐ إنشاء بيانات معدلة
        final profileData = Map<String, dynamic>.from(data);
        profileData['yearsOfExperience'] = yearsExpString;

        // ⭐ معالجة room إذا كانت موجودة
        if (data.containsKey('room')) {
          final roomData = data['room'];
          if (roomData is Map<String, dynamic>) {
            // ⭐ التحقق مما إذا كانت room فارغة
            if (roomData.isEmpty ||
                roomData['chatRoomId'] == null ||
                roomData['chatRoomId']?.toString().isEmpty == true) {
              profileData['room'] = null; // ⭐ تعيين null إذا كانت فارغة
            } else {
              // ⭐ تحويل isBlocked من List إلى boolean
              if (roomData.containsKey('isBlocked') &&
                  roomData['isBlocked'] is List) {
                final blockedList = roomData['isBlocked'] as List;
                roomData['isBlocked'] = blockedList.isNotEmpty;
              }
            }
          }
        }

        final profile = UserAdvisorProfileModel.fromJson(profileData);
        return Right(profile);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'profile_fetch_failed'),
        );
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
        endPoint: '/posts/all-for-advisor/$advisorId',
        query: {'page': page, 'limit': 10},
      );

      if (response['success'] == true) {
        final postsList =
            (response['data']?['postsDto'] as List<dynamic>?)
                ?.map((e) => PostModel.fromJson(e))
                .toList() ??
            [];
        return Right(postsList);
      } else {
        return Left(ServerFailure(response['message'] ?? 'posts_fetch_failed'));
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
      return Right(response['message'] ?? 'operation_success');
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
      return Right(response['message'] ?? 'operation_success');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> blockUser(String advisorId) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.blockuser,
        data: {"blockedId": advisorId},
      );
      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'user_blocked_success');
      }
      return Left(ServerFailure(response['message'] ?? 'error_occurred'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> savedPost({
    required String postId,
    required bool isRemove,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.savePost,
        data: {"postId": postId, "action": isRemove ? "remove" : "add"},
      );
      return Right(response['message'] ?? 'operation_success');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deletePost({required String postId}) async {
    try {
      final response = await _apiService.delete(
        endPoint: "/posts/delete/$postId",
      );
      return Right(response['message'] ?? 'operation_success');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  void hidePost({required String postId, required bool isHide}) async {
    final String action = isHide ? "add" : "remove";
    await _apiService.post(
      endPoint: '/posts/toggle-hide-post?postId=$postId&action=$action',
    );
  }

  @override
  Future<Either<Failure, String>> unblockUser(String advisorId) async {
    try {
      final response = await _apiService.delete(
        endPoint: ApiEndPoint.unblockuser,
        data: {"blockedId": advisorId},
      );
      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'unblock_success');
      }
      return Left(ServerFailure(response['message'] ?? 'error_occurred'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> archivePost({required String postId}) async {
    try {
      final response = await _apiService.post(
        endPoint: "/posts/toggle-archive-post",
        data: {"postId": postId},
      );
      return Right(response['message'] ?? 'operation_success');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> reportUser({
    required String reportedId,
    required String reason,
    required String reasonDetails,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint:
            '/personal-reports/', // افترض أن ده الـ endPoint الكامل، غيره لو مختلف
        data: {
          "reportedId": reportedId,
          "reason": reason,
          "reasonDetails": reasonDetails,
        },
      );
      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'report_sent_success');
      }
      return Left(ServerFailure(response['message'] ?? 'error_occurred'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
