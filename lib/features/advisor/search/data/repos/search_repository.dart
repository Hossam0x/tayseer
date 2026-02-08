import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/advisor/search/data/models/search_response_model.dart';

class SearchRepository {
  final ApiService _apiService;

  SearchRepository(this._apiService);

  Future<SearchResponseModel> search({
    required String query,
    String type = 'all',
  }) async {
    final response = await _apiService.get(
      endPoint: '/search',
      query: {'words': query, 'type': type},
    );

    return SearchResponseModel.fromJson(response, type);
  }
}
