import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../models/story_visibility_models.dart';

abstract class StoryVisibilityRepository {
  Future<Either<Failure, RestrictedUsersResponse>> getRestrictedUsers({
    String search = '',
  });

  Future<Either<Failure, UnrestrictResponse>> unrestrictUsers({
    required List<String> userIds,
  });
}

class StoryVisibilityRepositoryImpl implements StoryVisibilityRepository {
  final ApiService _apiService;

  StoryVisibilityRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, RestrictedUsersResponse>> getRestrictedUsers({
    String search = '',
  }) async {
    try {
      final Map<String, dynamic> query = {};
      if (search.isNotEmpty) {
        query['search'] = search;
      }

      final response = await _apiService.get(
        endPoint: '/story-visibility/my-restricted-users',
        query: query,
      );

      if (response['success'] == true) {
        final restrictedResponse = RestrictedUsersResponse.fromJson(response);
        return Right(restrictedResponse);
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ?? 'فشل جلب المستخدمين المقيدين',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UnrestrictResponse>> unrestrictUsers({
    required List<String> userIds,
  }) async {
    try {
      final request = UnrestrictRequest(userIds: userIds);

      final response = await _apiService.delete(
        endPoint: '/story-visibility/unrestrict',
        data: request.toJson(),
      );

      if (response['success'] == true) {
        final unrestrictResponse = UnrestrictResponse.fromJson(response);
        return Right(unrestrictResponse);
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ?? 'فشل إلغاء تقييد المستخدمين',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
