import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/models/result.dart';
import '../models/momo_models.dart';

class MomoRepository {
  final ApiService _api;

  MomoRepository(this._api);

  /// Tạo lệnh nạp tiền MoMo.
  /// Trả về [MomoCreateOrderResponse] với deeplink/payUrl để mở app MoMo.
  Future<Result<MomoCreateOrderResponse>> createDepositOrder({
    required double amount,
    String? orderInfo,
  }) async {
    return _api.post<MomoCreateOrderResponse>(
      ApiConstants.momoDepositCreate,
      data: {
        'amount': amount,
        if (orderInfo != null) 'orderInfo': orderInfo,
      },
      parser: (json) =>
          MomoCreateOrderResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Kiểm tra trạng thái lệnh nạp tiền (polling sau khi quay về app).
  Future<Result<String>> getDepositStatus(String orderId) async {
    return _api.get<String>(
      ApiConstants.momoDepositStatus(orderId),
      parser: (json) => json.toString(),
    );
  }

  /// Yêu cầu rút tiền từ ví TaskHub về ví MoMo.
  Future<Result<MomoWithdrawResponse>> requestWithdrawal({
    required double amount,
    required String phone,
  }) async {
    return _api.post<MomoWithdrawResponse>(
      ApiConstants.momoWithdrawRequest,
      data: {
        'amount': amount,
        'phone': phone,
      },
      parser: (json) =>
          MomoWithdrawResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
