import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/models/result.dart';
import '../models/portfolio_models.dart';

final portfolioRepositoryProvider = Provider((ref) {
  final apiService = ref.read(apiServiceProvider);
  return PortfolioRepository(apiService);
});

class PortfolioRepository {
  final ApiService _api;

  PortfolioRepository(this._api);

  Future<Result<List<PortfolioItemResponse>>> getMyPortfolio() async {
    return _api.get<List<PortfolioItemResponse>>(
      '/api/portfolio/me',
      parser: (json) => (json as List)
          .map((item) => PortfolioItemResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Result<List<PortfolioItemResponse>>> getPublicPortfolio(int userId) async {
    return _api.get<List<PortfolioItemResponse>>(
      '/api/portfolio/user/$userId',
      parser: (json) => (json as List)
          .map((item) => PortfolioItemResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Result<PortfolioItemResponse>> createItem(CreatePortfolioItemRequest request) async {
    return _api.post<PortfolioItemResponse>(
      '/api/portfolio',
      data: request.toJson(),
      parser: (json) => PortfolioItemResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<void>> deleteItem(int id) async {
    return _api.delete<void>('/api/portfolio/$id');
  }
}
