import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/home/model/post_response_model.dart';
import 'package:tayseer/features/advisor/home/reposiotry/home_repository.dart';
import '../../../../my_import.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiService apiService;

  HomeRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, List<PostModel>>> fetchPosts({
    required int page,
  }) async {
    try {
      var response = await apiService.get(
        endPoint: ApiEndPoint.posts,
        query: {'page': page},
      );
      final postsResponse = PostsResponseModel.fromJson(response);
      return Right(postsResponse.posts);
    } on DioException catch (error) {
      if (error.response != null && error.response!.data != null) {
        final errorMessage = error.response!.data['message'] ?? 'Unknown error';
        return Left(ServerFailure(errorMessage));
      } else {
        return Left(ServerFailure(error.message ?? 'Unknown error'));
      }
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
    apiService.post(endPoint: ApiEndPoint.like, data: requestData);
  }

  @override
  Future<Either<Failure, String>> sharePost({
    required String postId,
    required String action,
  }) async {
    try {
      final Map<String, dynamic> requestData = {"postId": postId};
      var response = await apiService.post(
        endPoint: "${ApiEndPoint.share}?action=$action",
        data: requestData,
      );
      // ✅ لو وصلنا هنا يعني 200 OK
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (error) {
      if (error.response != null && error.response!.data != null) {
        final errorMessage = error.response!.data['message'] ?? 'Unknown error';
        return Left(ServerFailure(errorMessage));
      } else {
        return Left(ServerFailure(error.message ?? 'Unknown error'));
      }
    }
  }
}
