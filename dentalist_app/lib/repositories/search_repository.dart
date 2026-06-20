import '../models/search_results.dart';
import '../services/api_service.dart';
import '../core/constants.dart';

class SearchRepository {
  final ApiService _api;

  SearchRepository(this._api);

  Future<SearchResults?> search(String query) async {
    try {
      final response = await _api.get(ApiConstants.search, queryParameters: {'q': query});
      return SearchResults.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
