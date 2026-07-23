import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/models/result.dart';
import '../../../../core/models/page_response.dart';
import '../models/review_models.dart';

final reviewRepositoryProvider = Provider((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ReviewRepository(apiService);
});

class ReviewRepository {
  final ApiService _api;

  ReviewRepository(this._api);

  Future<Result<PageResponse<ReviewResponse>>> getReviewsForUser(int userId, {int page = 0, int size = 20}) async {
    return _api.get<PageResponse<ReviewResponse>>(
      '/api/reviews/user/$userId',
      queryParameters: {'page': page, 'size': size},
      parser: (json) => PageResponse.fromJson(
          json as Map<String, dynamic>, (item) => ReviewResponse.fromJson(item as Map<String, dynamic>)),
    );
  }

  Future<Result<ReviewResponse>> createReview(CreateReviewRequest request) async {
    return _api.post<ReviewResponse>(
      '/api/reviews',
      data: request.toJson(),
      parser: (json) => ReviewResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
