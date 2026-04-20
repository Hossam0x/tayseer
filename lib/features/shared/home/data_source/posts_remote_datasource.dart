import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/features/shared/home/model/best_advisor_model.dart';
import 'package:tayseer/features/shared/home/model/past_match_model.dart';
import 'package:tayseer/features/shared/home/model/post_response_model.dart';
import 'package:tayseer/features/shared/home/model/similar_user_model.dart';

/// مصدر البيانات عن بعد للبوستات — يتعامل مع API فقط
class PostsRemoteDatasource {
  final ApiService _apiService;

  PostsRemoteDatasource(this._apiService);

  /// جلب البوستات من الـ API — يرمي DioException عند الفشل
  Future<PostsResponseModel> fetchPosts({
    required int page,
    double? nextCursor,
    String? categoryId,
  }) async {
    final response = await _apiService.get(
      endPoint: ApiEndPoint.posts,
      query: {
        'page': page,
        if (categoryId != null) 'categoryId': categoryId,
        if (nextCursor != null) 'nextCursor': nextCursor,
      },
    );
    return PostsResponseModel.fromJson(response);
  }

  Future<BestAdvisorResponse> fetchBestAdvisors() async {
    final response = await _apiService.get(endPoint: ApiEndPoint.bestAdvisors);
    return BestAdvisorResponse.fromJson(response);
  }

  Future<SimilarUserResponse> fetchSimilarUsers() async {
    final response = await _apiService.get(endPoint: ApiEndPoint.similarUsers);
    return SimilarUserResponse.fromJson(response);
  }

  Future<PastMatchesResponse> fetchPastMatches() async {
    final response = await _apiService.get(endPoint: ApiEndPoint.pastMatches);
    return PastMatchesResponse.fromJson(response);
  }
}
