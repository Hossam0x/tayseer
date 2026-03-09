import 'package:dartz/dartz.dart';
import 'package:tayseer/core/functions/upload_imageandvideo_to_api.dart';
import 'package:tayseer/core/models/category_model.dart';
import 'package:tayseer/core/models/pagination_model.dart';
import 'package:tayseer/features/advisor/add_post/model/category_response_model.dart';
import 'package:tayseer/my_import.dart';

import 'posts_repository.dart';

class PostsRepositoryImpl implements PostsRepository {
  PostsRepositoryImpl({required this.apiService});
  final ApiService apiService;

  Future<MultipartFile> _fileToMultipart(File file) async {
    final filename = file.path.split(Platform.pathSeparator).isNotEmpty
        ? file.path.split(Platform.pathSeparator).last
        : (file.uri.pathSegments.isNotEmpty
              ? file.uri.pathSegments.last
              : 'file');
    return MultipartFile.fromFile(file.path, filename: filename);
  }

  @override
  Future<Either<Failure, void>> createPost({
    String? content,
    required String categoryId,
    required String postType,
    List<AssetEntity>? images,
    List<File>? imageFiles,
    XFile? videoFile,
  }) async {
    try {
      List<MultipartFile> uploadedImages = [];
      if (images != null) {
        for (final asset in images) {
          final file = await asset.file;
          if (file != null) {
            uploadedImages.add(await _fileToMultipart(file));
          }
        }
      }
      if (imageFiles != null) {
        for (final file in imageFiles) {
          uploadedImages.add(await _fileToMultipart(file));
        }
      }

      /// form data
      final data = <String, dynamic>{
        if (content != null) 'content': content,
        'categoryId': categoryId,
        'postType': postType,
        if (uploadedImages.isNotEmpty) 'images': uploadedImages,
        if (videoFile != null) 'videos': await uploadVideoToApi(videoFile),
      };

      final response = await apiService.post(
        endPoint: '/posts/create',
        isFromData: true,
        data: data,
      );

      final success = response['success'] ?? false;

      if (success) {
        return right(null);
      } else {
        return left(ServerFailure(response['message'] ?? 'فشل إنشاء المنشور'));
      }
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'خطأ في الاتصال بالخادم';
      return left(ServerFailure(message));
    } catch (error) {
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }

  @override
  Future<Either<Failure, CategoryResponse>> getALLCategory(String? page) async {
    try {
      final response = await apiService.get(
        endPoint: '/category',
        query: {if (page != null) 'page': page},
      );

      final data = response['data'];

      // 📌 Categories
      final categoriesJson = data['categories'] as List;

      List<CategoryModel> results = categoriesJson
          .map((category) => CategoryModel.fromJson(category))
          .toList();

      // 📌 Pagination
      final paginationJson = data['pagination'];

      final pagination = PaginationModel.fromJson(paginationJson);

      debugPrint(
        'Category fetched: ${results.length} | Page: ${pagination.currentPage}/${pagination.totalPages}',
      );

      return Right(
        CategoryResponse(categories: results, pagination: pagination),
      );
    } on DioException catch (error) {
      return Left(
        ServerFailure(error.response?.data['message'] ?? 'حدث خطأ في السيرفر'),
      );
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePosts({
    String? idPost,
    String? content,
    required String categoryId,
    required String postType,
    List<File>? imageFiles,
    List<String>? imagesToDelete,
    List<String>? videosToDelete,
    XFile? videoFile,
  }) async {
    try {
      List<MultipartFile> uploadedImages = [];

      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (final file in imageFiles) {
          uploadedImages.add(await _fileToMultipart(file));
        }
      }

      final data = <String, dynamic>{
        'content': content ?? '',
        'categoryId': categoryId,
        'postType': postType,
        if (uploadedImages.isNotEmpty) 'images': uploadedImages,
        if (videoFile != null) 'videos': await uploadVideoToApi(videoFile),
        if (imagesToDelete != null && imagesToDelete.isNotEmpty)
          'imagesToDelete[]': imagesToDelete,
        if (videosToDelete != null && videosToDelete.isNotEmpty)
          'videosToDelete[]': videosToDelete,
      };

      final response = await apiService.patch(
        endPoint: '/posts/update/$idPost',
        isFromData: true,
        data: data,
      );

      final success = response['success'] ?? false;

      if (success) {
        return right(null);
      } else {
        return left(ServerFailure(response['message'] ?? 'فشل تعديل المنشور'));
      }
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'خطأ في الاتصال بالخادم';
      return left(ServerFailure(message));
    } catch (error) {
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }
}
