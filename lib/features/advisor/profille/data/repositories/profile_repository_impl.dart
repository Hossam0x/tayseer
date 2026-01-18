import 'package:dartz/dartz.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/my_import.dart';
import 'profile_repository.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService _apiService;

  ProfileRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, ProfileModel>> getAdvisorProfile() async {
    try {
      final response = await _apiService.get(endPoint: ApiEndPoint.profileData);

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;

        // تنظيف نص سنوات الخبرة
        String? yearsExpString = data['yearsOfExperience']?.toString();
        if (yearsExpString != null && yearsExpString.isNotEmpty) {
          yearsExpString = yearsExpString.replaceAll(" من الخبرة", "");
        }

        // إنشاء بيانات البروفايل مع الحقول الجديدة
        final profileData = Map<String, dynamic>.from(data);
        profileData['yearsOfExperience'] = yearsExpString;

        // ⭐ تأكد من وجود الحقول الجديدة في الـ Response
        profileData['professionalSpecialization'] =
            data['ProfessionalSpecialization'] ??
            data['professionalSpecialization'];

        profileData['jobGrade'] = data['JobGrade'] ?? data['jobGrade'];

        final profile = ProfileModel.fromJson(profileData);
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
  Future<Either<Failure, List<PostModel>>> fetchSavedPosts({
    required int page,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/posts/all',
        query: {'page': page},
      );

      if (response['success'] == true) {
        final postsList =
            (response['data']?['postsDto'] as List<dynamic>?)
                ?.map((e) => PostModel.fromJson(e))
                .toList() ??
            [];
        return Right(postsList);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل جلب المنشورات المحفوظة'),
        );
      }
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
