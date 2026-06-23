import 'package:json_annotation/json_annotation.dart';

part 'wallet_models.g.dart';

@JsonSerializable()
class WalletResponse {
  final double balance;

  WalletResponse({required this.balance});

  factory WalletResponse.fromJson(Map<String, dynamic> json) =>
      _$WalletResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WalletResponseToJson(this);
}

@JsonSerializable()
class WalletTransactionResponse {
  final int id;
  final String type;
  final double amount;
  @JsonKey(name: 'balanceAfter')
  final double? balanceAfter;
  @JsonKey(name: 'taskId')
  final int? taskId;
  @JsonKey(name: 'createdAt')
  final String createdAt;

  WalletTransactionResponse({
    required this.id, required this.type, required this.amount,
    this.balanceAfter, this.taskId, required this.createdAt,
  });

  factory WalletTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WalletTransactionResponseToJson(this);

  String get typeLabel {
    switch (type) {
      case 'top_up': return 'Nap tien';
      case 'escrow_deduction': return 'Tru escrow';
      case 'refund': return 'Hoan tien';
      case 'escrow_release': return 'Giai phong escrow';
      case 'withdrawal': return 'Rut tien';
      default: return type;
    }
  }

  bool get isPositive =>
      type == 'top_up' || type == 'refund' || type == 'escrow_release';
}

@JsonSerializable()
class WalletReadinessResponse {
  final bool sufficient;
  final double budget;
  final double platformFee;
  @JsonKey(name: 'requiredTotal')
  final double requiredTotal;
  @JsonKey(name: 'currentBalance')
  final double currentBalance;
  final double shortfall;
  final String? action;
  @JsonKey(name: 'resumeFlow')
  final String? resumeFlow;

  WalletReadinessResponse({
    required this.sufficient, required this.budget, required this.platformFee,
    required this.requiredTotal, required this.currentBalance,
    required this.shortfall, this.action, this.resumeFlow,
  });

  factory WalletReadinessResponse.fromJson(Map<String, dynamic> json) =>
      _$WalletReadinessResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WalletReadinessResponseToJson(this);
}
