import 'package:dartz/dartz.dart';
import 'package:tayseer/core/services/connectivity_service.dart';
import 'package:tayseer/features/shared/home/data_source/posts_local_datasource.dart';
import 'package:tayseer/features/shared/home/data_source/posts_remote_datasource.dart';
import 'package:tayseer/features/shared/home/model/Image_and_name_model.dart';
import 'package:tayseer/features/shared/home/model/categories_response_model.dart';
import 'package:tayseer/core/models/comment_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/models/pagination_model.dart';
import 'package:tayseer/features/shared/home/model/post_response_model.dart';
import 'package:tayseer/features/shared/home/model/comments_response_model.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import '../../../../my_import.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiService apiService;
  final PostsLocalDatasource localDatasource;
  final PostsRemoteDatasource remoteDatasource;
  final ConnectivityService connectivityService;

  HomeRepositoryImpl(
    this.apiService, {
    required this.localDatasource,
    required this.remoteDatasource,
    required this.connectivityService,
  });

  // ================= Posts =================

  @override
  Future<Either<Failure, PostsResponseModel>> fetchPosts({
    required int page,
    double? nextCursor,
    String? categoryId,
  }) async {
    final isOnline = connectivityService.isConnected;

    if (isOnline) {
      return _fetchPostsOnline(
        page: page,
        nextCursor: nextCursor,
        categoryId: categoryId,
      );
    } else {
      return _fetchPostsOffline(page: page, categoryId: categoryId);
    }
  }

  /// جلب البوستات أونلاين — مع حفظ صامت في الكاش
  Future<Either<Failure, PostsResponseModel>> _fetchPostsOnline({
    required int page,
    double? nextCursor,
    String? categoryId,
  }) async {
    try {
      final response = await remoteDatasource.fetchPosts(
        page: page,
        nextCursor: nextCursor,
        categoryId: categoryId,
      );

      // ✅ الكاش التراكمي ينحفظ من الـ Cubit بعد تجميع كل البوستات
      // هنا نحفظ فقط لو صفحة 1 (أول تحميل)
      if (categoryId == null && page == 1) {
        localDatasource
            .cachePosts(
              response.posts,
              nextCursor: response.nextCursor,
              page: page,
            )
            .catchError((_) {});
      }

      return Right(response);
    } on DioException catch (e) {
      // لو فشل الـ API وموجود كاش — استخدم الكاش كـ fallback
      if (categoryId == null && page == 1) {
        final cachedResult = await localDatasource.getCachedPosts();
        if (cachedResult != null && cachedResult.posts.isNotEmpty) {
          return Right(
            PostsResponseModel(
              success: true,
              message: 'from_cache',
              posts: cachedResult.posts,
              pagination: PaginationModel(
                totalCount: cachedResult.posts.length,
                totalPages: cachedResult.lastPage,
                currentPage: 1,
                pageSize: cachedResult.posts.length,
              ),
              nextCursor: cachedResult.nextCursor,
            ),
          );
        }
      }
      // لو خطأ اتصال وما فيش كاش → يرجع NetworkFailure بدل ServerFailure
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return Left(NetworkFailure.offlineNoCache());
      }
      return Left(ServerFailure.fromDioError(e));
    }
  }

  /// جلب البوستات أوفلاين — من الكاش مع باجنيشن محلي
  Future<Either<Failure, PostsResponseModel>> _fetchPostsOffline({
    required int page,
    String? categoryId,
  }) async {
    // نعرض الكاش فقط للـ "All" category
    if (categoryId == null) {
      final cachedResult = await localDatasource.getCachedPostsPaginated(
        page: page,
        pageSize: 5,
      );
      if (cachedResult != null && cachedResult.posts.isNotEmpty) {
        return Right(
          PostsResponseModel(
            success: true,
            message: 'from_cache',
            posts: cachedResult.posts,
            pagination: PaginationModel(
              totalCount: cachedResult.posts.length,
              totalPages: cachedResult.lastPage,
              currentPage: page,
              pageSize: cachedResult.posts.length,
            ),
            nextCursor: cachedResult.nextCursor,
          ),
        );
      } else {
        // صفحة 1 فاضية = مافيش كاش أصلاً
        if (page == 1) return Left(NetworkFailure.offlineNoCache());
        // صفحة > 1 فاضية = خلصنا الكاش
        return Left(NetworkFailure.offline());
      }
    }

    // أي كاتيجوري ثانية أوفلاين → خطأ
    return Left(NetworkFailure.offline());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 Cache Sync Helpers — تحديث الكاش بعد التفاعلات الناجحة
  // ═══════════════════════════════════════════════════════════════════════════

  /// حذف بوست من الكاش
  void _removePostFromCache(String postId) {
    localDatasource.removePost(postId).catchError((_) {});
  }

  /// حذف كل بوستات مستشار من الكاش
  void _removeAdvisorPostsFromCache(String advisorId) {
    localDatasource.removePostsByAdvisor(advisorId).catchError((_) {});
  }

  @override
  Future<Either<Failure, String>> reactToPost({
    required String postId,
    required ReactionType? reactionType,
    required bool isRemove,
  }) async {
    try {
      final data = {
        "postId": postId,
        if (!isRemove) "type": reactionType!.name,
        'action': isRemove ? 'remove' : 'add',
      };

      final response = await apiService.post(
        endPoint: ApiEndPoint.like,
        data: data,
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> sharePost({
    required String postId,
    required String action,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.share,
        query: {'action': action},
        data: {"postId": postId},
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  // ================= Comments =================

  @override
  Future<Either<Failure, CommentsResponseModel>> fetchComments({
    required String postId,
    required int page,
  }) async {
    try {
      final response = await apiService.get(
        endPoint: '${ApiEndPoint.comments}/$postId/comments',
        query: {'page': page},
      );
      return Right(CommentsResponseModel.fromJson(response));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, CommentsResponseModel>> fetchReplies({
    required String commentId,
    required int page,
  }) async {
    try {
      final response = await apiService.get(
        endPoint: '${ApiEndPoint.replies}$commentId',
        query: {'page': page, 'limit': 5},
      );
      return Right(CommentsResponseModel.fromJson(response));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, CommentModel>> addComment({
    required String postId,
    required String comment,
    required bool anonymous,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.comments,
        data: {"postId": postId, "comment": comment, "anonymous": anonymous},
      );
      return Right(CommentModel.fromJson(response['data']));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, CommentModel>> addReply({
    required String commentId,
    required String reply,
    required bool anonymous,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.createReply,
        data: {"commentId": commentId, "reply": reply, "anonymous": anonymous},
      );
      return Right(CommentModel.fromJson(response['data']));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<void> likeToggle({
    String? commentId,
    String? replyId,
    required bool isRemove,
  }) async {
    await apiService.post(
      endPoint: ApiEndPoint.commentLike,
      query: {'action': isRemove ? 'remove' : 'add'},
      data: {
        if (commentId != null) "commentId": commentId,
        if (replyId != null) "replyId": replyId,
      },
    );
  }

  @override
  Future<Either<Failure, String>> editComment({
    required String commentId,
    required String comment,
  }) async {
    try {
      final response = await apiService.patch(
        endPoint: ApiEndPoint.comments,
        data: {"commentId": commentId, "comment": comment},
      );
      return Right(response['message'] ?? 'تم تعديل التعليق بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> editReply({
    required String replyId,
    required String reply,
  }) async {
    try {
      final response = await apiService.patch(
        endPoint: '${ApiEndPoint.updateReply}$replyId',
        data: {"reply": reply},
      );
      return Right(response['message'] ?? 'تم تعديل الرد بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> deleteComment({
    required String commentId,
  }) async {
    try {
      final response = await apiService.delete(
        endPoint: "${ApiEndPoint.comments}/$commentId",
      );

      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'تم حذف التعليق بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> deleteReply({required String replyId}) async {
    try {
      final response = await apiService.delete(
        endPoint: "${ApiEndPoint.deleteReply}$replyId",
      );
      return Right(response['message'] ?? 'تم حذف الرد بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  void hideComment({required String commentId, required bool isHide}) {
    apiService.post(
      endPoint: ApiEndPoint.hideComment,
      query: {'action': isHide ? 'add' : 'remove'},
      data: {"commentId": commentId},
    );
  }

  @override
  void hideReply({required String replyId, required bool isHide}) {
    apiService.post(
      endPoint: ApiEndPoint.hideReply,
      query: {'action': isHide ? 'add' : 'remove'},
      data: {"replyId": replyId},
    );
  }

  // ================= Reels =================

  @override
  Future<Either<Failure, List<PostModel>>> getReels({
    required int page,
    int limit = 5,
  }) async {
    try {
      final response = await apiService.get(
        endPoint: ApiEndPoint.reels,
        query: {'page': page, 'limit': limit},
      );

      final reels =
          (response['data']?['reelsDto'] as List<dynamic>?)
              ?.map((e) => PostModel.fromJson(e))
              .toList() ??
          [];

      return Right(reels);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  // ================= Profile =================

  @override
  Future<Either<Failure, ImageAndNameModel>> fetchNameAndImage() async {
    try {
      // Guest users don't have a /user/profile endpoint — read from cache
      if (isGuest) {
        final name =
            (await CachNetwork.getData(key: kGuestName)) as String? ?? '';
        final image =
            (await CachNetwork.getData(key: kGuestImage)) as String? ?? '';
        return Right(
          ImageAndNameModel(image: image, name: name, notifications: 0),
        );
      }

      final endPoint = isAdvisor ? ApiEndPoint.nameAndImage : '/user/profile';
      final response = await apiService.get(endPoint: endPoint);

      if (isAdvisor) {
        return Right(ImageAndNameModel.fromJson(response['data']));
      } else {
        final data = response['data'] as Map<String, dynamic>;
        return Right(
          ImageAndNameModel(
            image: data['image'] as String? ?? '',
            name: data['name'] as String? ?? '',
            notifications: data['notifyCount'] as int? ?? 0,
          ),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  // ================= Categories =================

  @override
  Future<Either<Failure, CategoriesResponseModel>> fetchAllCategories(
    int page,
  ) async {
    try {
      final response = await apiService.get(
        endPoint: ApiEndPoint.category,
        query: {'page': page},
      );
      return Right(CategoriesResponseModel.fromJson(response));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  // ================= Post Actions =================

  @override
  Future<Either<Failure, String>> savedPost({
    required String postId,
    required bool isRemove,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.savePost,
        query: {'action': isRemove ? 'remove' : 'add'},
        data: {"postId": postId},
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> deletePost({required String postId}) async {
    try {
      final response = await apiService.delete(
        endPoint: "${ApiEndPoint.deletePost}$postId",
      );

      if (response['success'] == true || response['status'] == 'success') {
        _removePostFromCache(postId);
        return Right(response['message'] ?? 'تم حذف المنشور بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> hidePost({
    required String postId,
    required bool isHide,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.hidePost,
        query: {'action': isHide ? 'add' : 'remove'},
        data: {"postId": postId},
      );

      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'تمت العملية بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> blockUser({required String userId}) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.blockuser,
        data: {"blockedId": userId},
      );

      if (response['success'] == true || response['status'] == 'success') {
        _removeAdvisorPostsFromCache(userId);
        return Right(response['message'] ?? 'تم حظر المستخدم بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> archivePost({required String postId}) async {
    try {
      final response = await apiService.post(
        endPoint: "${ApiEndPoint.archivePost}$postId",
        query: {'action': 'add'},
      );

      if (response['success'] == true || response['status'] == 'success') {
        _removePostFromCache(postId);
        return Right(response['message'] ?? 'تم أرشفة المنشور بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> voteInPoll({
    required String postId,
    required String choiceIndex,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.vote,
        data: {"postId": postId, "choiceIndex": choiceIndex},
      );
      if (response['success'] == true || response['status'] == 'success') {
        return Right(true);
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> followAdvisor({
    required String advisorId,
    required bool isAdding,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: "${ApiEndPoint.followAdvisor}$advisorId",
        query: {'action': isAdding ? 'add' : 'remove'},
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}
