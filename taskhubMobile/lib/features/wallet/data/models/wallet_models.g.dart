// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletResponse _$WalletResponseFromJson(Map<String, dynamic> json) =>
    WalletResponse(balance: (json['balance'] as num).toDouble());

Map<String, dynamic> _$WalletResponseToJson(WalletResponse instance) =>
    <String, dynamic>{'balance': instance.balance};

WalletTransactionResponse _$WalletTransactionResponseFromJson(
  Map<String, dynamic> json,
) => WalletTransactionResponse(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
  taskId: (json['taskId'] as num?)?.toInt(),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$WalletTransactionResponseToJson(
  WalletTransactionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'amount': instance.amount,
  'balanceAfter': instance.balanceAfter,
  'taskId': instance.taskId,
  'createdAt': instance.createdAt,
};

WalletReadinessResponse _$WalletReadinessResponseFromJson(
  Map<String, dynamic> json,
) => WalletReadinessResponse(
  sufficient: json['sufficient'] as bool,
  budget: (json['budget'] as num).toDouble(),
  platformFee: (json['platformFee'] as num).toDouble(),
  requiredTotal: (json['requiredTotal'] as num).toDouble(),
  currentBalance: (json['currentBalance'] as num).toDouble(),
  shortfall: (json['shortfall'] as num).toDouble(),
  action: json['action'] as String?,
  resumeFlow: json['resumeFlow'] as String?,
);

Map<String, dynamic> _$WalletReadinessResponseToJson(
  WalletReadinessResponse instance,
) => <String, dynamic>{
  'sufficient': instance.sufficient,
  'budget': instance.budget,
  'platformFee': instance.platformFee,
  'requiredTotal': instance.requiredTotal,
  'currentBalance': instance.currentBalance,
  'shortfall': instance.shortfall,
  'action': instance.action,
  'resumeFlow': instance.resumeFlow,
};

SepayBankConfig _$SepayBankConfigFromJson(Map<String, dynamic> json) =>
    SepayBankConfig(
      bankCode: json['bankCode'] as String,
      bankAccount: json['bankAccount'] as String,
      bankName: json['bankName'] as String,
      accountName: json['accountName'] as String,
      qrTemplate: json['qrTemplate'] as String,
      minDepositAmount: (json['minDepositAmount'] as num?)?.toDouble(),
      maxDepositAmount: (json['maxDepositAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SepayBankConfigToJson(SepayBankConfig instance) =>
    <String, dynamic>{
      'bankCode': instance.bankCode,
      'bankAccount': instance.bankAccount,
      'bankName': instance.bankName,
      'accountName': instance.accountName,
      'qrTemplate': instance.qrTemplate,
      'minDepositAmount': instance.minDepositAmount,
      'maxDepositAmount': instance.maxDepositAmount,
    };

PayoutRequestResponse _$PayoutRequestResponseFromJson(
  Map<String, dynamic> json,
) => PayoutRequestResponse(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  userName: json['userName'] as String,
  userEmail: json['userEmail'] as String,
  amount: (json['amount'] as num).toDouble(),
  bankCode: json['bankCode'] as String,
  accountNumber: json['accountNumber'] as String,
  accountName: json['accountName'] as String,
  status: json['status'] as String,
  statusLabel: json['statusLabel'] as String,
  adminNote: json['adminNote'] as String?,
  createdAt: json['createdAt'] as String,
  qrUrl: json['qrUrl'] as String?,
);

Map<String, dynamic> _$PayoutRequestResponseToJson(
  PayoutRequestResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'userEmail': instance.userEmail,
  'amount': instance.amount,
  'bankCode': instance.bankCode,
  'accountNumber': instance.accountNumber,
  'accountName': instance.accountName,
  'status': instance.status,
  'statusLabel': instance.statusLabel,
  'adminNote': instance.adminNote,
  'createdAt': instance.createdAt,
  'qrUrl': instance.qrUrl,
};
