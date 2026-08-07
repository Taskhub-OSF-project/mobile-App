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

@JsonSerializable()
class SepayBankConfig {
  final String bankCode;
  final String bankAccount;
  final String bankName;
  final String accountName;
  final String qrTemplate;
  final double? minDepositAmount;
  final double? maxDepositAmount;

  SepayBankConfig({
    required this.bankCode,
    required this.bankAccount,
    required this.bankName,
    required this.accountName,
    required this.qrTemplate,
    this.minDepositAmount,
    this.maxDepositAmount,
  });

  factory SepayBankConfig.fromJson(Map<String, dynamic> json) =>
      _$SepayBankConfigFromJson(json);

  Map<String, dynamic> toJson() => _$SepayBankConfigToJson(this);
}

@JsonSerializable()
class PayoutRequestResponse {
  final int id;
  final int userId;
  final String userName;
  final String userEmail;
  final double amount;
  final String bankCode;
  final String accountNumber;
  final String accountName;
  final String status;
  final String statusLabel;
  final String? adminNote;
  final String createdAt;
  final String? qrUrl;

  PayoutRequestResponse({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.amount,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
    required this.status,
    required this.statusLabel,
    this.adminNote,
    required this.createdAt,
    this.qrUrl,
  });

  factory PayoutRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$PayoutRequestResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PayoutRequestResponseToJson(this);
}
