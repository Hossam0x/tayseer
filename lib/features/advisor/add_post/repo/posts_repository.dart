import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/add_post/model/category_response_model.dart';
import 'package:tayseer/features/advisor/add_post/model/created_post_data.dart';
import 'package:tayseer/my_import.dart';

abstract class PostsRepository {
  /// Create a new post with optional images, videos and gifs.
  /// Returns [CreatedPostData] with the real post ID from the server.
  Future<Either<Failure, CreatedPostData>> createPost({
    String? content,
    required String categoryId,
    required String postType,
    List<AssetEntity>? images,
    List<File>? imageFiles,
    XFile? videoFile,
  });
  Future<Either<Failure, void>> updatePosts({
    String? idPost,
    String? content,
    required String categoryId,
    required String postType,
    List<File>? imageFiles,
    List<String>? imagesToDelete,
    List<String>? videosToDelete,

    XFile? videoFile,
  });

  Future<Either<Failure, CategoryResponse>> getALLCategory(String? page);
}
