import 'package:json_annotation/json_annotation.dart';

part 'momo_models.g.dart';

/// Trạng thái của lệnh MoMo
enum MomoTransactionStatus { PENDING, SUCCESS, FAILED, CANCELLED }

/// Response khi tạo lệnh nạp tiền thành công
@JsonSerializable()
class MomoCreateOrderResponse {
  final String orderId;
  final String? deeplink;
  final String? payUrl;
  final String? qrCodeUrl;
  final double amount;
  final String status;
  final String? message;

  MomoCreateOrderResponse({
    required this.orderId,
    this.deeplink,
    this.payUrl,
    this.qrCodeUrl,
    required this.amount,
    required this.status,
    this.message,
  });

  factory MomoCreateOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$MomoCreateOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MomoCreateOrderResponseToJson(this);

  /// Ưu tiên deeplink (mở app MoMo), fallback về payUrl
  String? get launchUrl => deeplink?.isNotEmpty == true ? deeplink : payUrl;
}

/// Response khi yêu cầu rút tiền
@JsonSerializable()
class MomoWithdrawResponse {
  final String orderId;
  final String status;
  final double amount;
  final double? newBalance;
  final String? message;
  final String? momoTransId;

  MomoWithdrawResponse({
    required this.orderId,
    required this.status,
    required this.amount,
    this.newBalance,
    this.message,
    this.momoTransId,
  });

  factory MomoWithdrawResponse.fromJson(Map<String, dynamic> json) =>
      _$MomoWithdrawResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MomoWithdrawResponseToJson(this);

  bool get isSuccess => status == 'SUCCESS';
}
