import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/models/api_response.dart';
import '../models/wallet_models.dart';

class WalletRepository {
  final ApiService _api;

  WalletRepository(this._api);

  Future<Result<WalletResponse>> getBalance() async {
    final response = await _api.get<WalletResponse>(
      ApiConstants.walletBalance,
      parser: (json) =>
          WalletResponse.fromJson(json['data'] as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<WalletReadinessResponse>> checkCreateTaskReadiness(
      double budget) async {
    final response = await _api.get<WalletReadinessResponse>(
      ApiConstants.walletReadiness,
      queryParameters: {'budget': budget},
      parser: (json) => WalletReadinessResponse.fromJson(
          json['data'] as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<WalletResponse>> deposit(double amount) async {
    final response = await _api.post<WalletResponse>(
      ApiConstants.walletDeposit,
      queryParameters: {'amount': amount},
      parser: (json) =>
          WalletResponse.fromJson(json['data'] as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<WalletResponse>> withdraw(double amount) async {
    final response = await _api.post<WalletResponse>(
      ApiConstants.walletWithdraw,
      queryParameters: {'amount': amount},
      parser: (json) =>
          WalletResponse.fromJson(json['data'] as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<PageResponse<WalletTransactionResponse>>> getTransactionsPaged({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _api.get<PageResponse<WalletTransactionResponse>>(
      ApiConstants.walletTransactionsPaged,
      queryParameters: {'page': page, 'size': size},
      parser: (json) => PageResponse<WalletTransactionResponse>.fromJson(
        json['data'] as Map<String, dynamic>,
        (e) => WalletTransactionResponse.fromJson(e as Map<String, dynamic>),
      ),
    );
    return response;
  }
}
