import 'dart:developer';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/add_post/model/category_model.dart';
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
    AssetEntity? videos,
  }) async {
    try {
      List<MultipartFile> uploadedImages = [];
      if (images != null && images.isNotEmpty) {
        for (final asset in images) {
          final file = await asset.file;
          if (file != null) {
            uploadedImages.add(await _fileToMultipart(file));
          }
        }
      }

      List<MultipartFile> uploadedVideos = [];
      if (videos != null) {
        final file = await videos.file;
        if (file != null) {
          uploadedVideos.add(await _fileToMultipart(file));
        }
      }

      final data = <String, dynamic>{
        if (content != null) 'content': content,
        'categoryId': categoryId,
        'postType': postType,
        if (uploadedImages.isNotEmpty) 'images': uploadedImages,
        if (uploadedVideos.isNotEmpty) 'video': uploadedVideos.first,
      };
      log('Create Post Data: $data');
      log('Number of Images: $uploadedImages');
      log('Number of Videos: $uploadedVideos');
      final response = await apiService.post(
        endPoint: '/posts/create',
        isFromData: true,
        isAuth: true,
        data: data,
      );
      log('Create Post Response: $response');
      final success = response['success'] ?? false;
      if (success) {
        return right(null);
      } else {
        final message = response['message'] ?? 'فشل إنشاء المنشور';
        return left(ServerFailure(message));
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
  Future<Either<Failure, List<CategoryModel>>> getALLCategory() async {
    try {
      final response = await apiService.get(endPoint: '/category');
      final packagesJson = response['data'] as List;

      List<CategoryModel> results = packagesJson
          .map((package) => CategoryModel.fromJson(package))
          .toList();

      debugPrint('category fetched: $results');

      return Right(results);
    } on DioException catch (error) {
      return left(error.response?.data['message']);
    } catch (e) {
      debugPrint('Error fetching packages: $e');
      return Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    }
  }
}
