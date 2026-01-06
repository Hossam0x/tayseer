import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/add_post/model/category_model.dart';
import 'package:tayseer/my_import.dart';

abstract class PostsRepository {
  /// Create a new post with optional images, videos and gifs.
  Future<Either<Failure, void>> createPost({
    String? content,
    required String categoryId,
    required String postType,
    List<AssetEntity>? images,
    AssetEntity? videos,
  });
  Future<Either<Failure, List<CategoryModel>>> getALLCategory();
}
