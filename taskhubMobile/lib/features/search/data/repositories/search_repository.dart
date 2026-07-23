import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/models/result.dart';
import '../../../../core/models/page_response.dart';
import '../../../task/data/models/task_models.dart';
import '../models/search_models.dart';

final searchRepositoryProvider = Provider((ref) {
  final apiService = ref.read(apiServiceProvider);
  return SearchRepository(apiService);
});

class SearchRepository {
  final ApiService _api;

  SearchRepository(this._api);

  Future<Result<PageResponse<FreelancerSearchResponse>>> searchFreelancers({
    String? query,
    List<String>? skills,
    int page = 0,
    int size = 20,
  }) async {
    return _api.get<PageResponse<FreelancerSearchResponse>>(
      '/api/search/freelancers',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (skills != null && skills.isNotEmpty) 'skills': skills.join(','),
        'page': page,
        'size': size,
      },
      parser: (json) => PageResponse.fromJson(
          json as Map<String, dynamic>, (item) => FreelancerSearchResponse.fromJson(item as Map<String, dynamic>)),
    );
  }

  Future<Result<PageResponse<TaskResponse>>> searchTasks({
    String? query,
    String? category,
    int page = 0,
    int size = 20,
  }) async {
    return _api.get<PageResponse<TaskResponse>>(
      '/api/search/tasks',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (category != null && category.isNotEmpty) 'category': category,
        'page': page,
        'size': size,
      },
      parser: (json) => PageResponse.fromJson(
          json as Map<String, dynamic>, (item) => TaskResponse.fromJson(item as Map<String, dynamic>)),
    );
  }

  Future<Result<List<String>>> getCategories() async {
    return _api.get<List<String>>(
      '/api/search/categories',
      parser: (json) => (json as List).map((e) => e.toString()).toList(),
    );
  }
}
