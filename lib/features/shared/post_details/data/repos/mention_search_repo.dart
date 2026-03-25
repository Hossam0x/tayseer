import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/shared/post_details/data/models/mention_search_model.dart';

class MentionSearchRepository {
  final ApiService apiService;

  MentionSearchRepository(this.apiService);

  Future<Either<Failure, List<MentionSearchModel>>> searchMentions(
    String query,
  ) async {
    try {
      final response = await apiService.get(
        endPoint: '/search',
        query: {'words': query, 'type': 'mentions', "limit": 15},
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data']['mentions'] ?? [];
        final mentions = data
            .map((e) => MentionSearchModel.fromJson(e))
            .toList();
        return Right(mentions);
      } else {
        return Left(ServerFailure(response['message'] ?? 'حدث خطأ غير متوقع'));
      }
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.data != null &&
          e.response!.data is Map &&
          e.response!.data['message'] != null) {
        return Left(ServerFailure(e.response!.data['message']));
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
