// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_models.dart';

WalletResponse _$WalletResponseFromJson(Map<String, dynamic> json) =>
    WalletResponse(
      balance: (json['balance'] as num).toDouble(),
    );

Map<String, dynamic> _$WalletResponseToJson(WalletResponse instance) =>
    <String, dynamic>{
      'balance': instance.balance,
    };

WalletTransactionResponse _$WalletTransactionResponseFromJson(
        Map<String, dynamic> json) =>
    WalletTransactionResponse(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      taskId: (json['taskId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$WalletTransactionResponseToJson(
        WalletTransactionResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'balanceAfter': instance.balanceAfter,
      'taskId': instance.taskId,
      'createdAt': instance.createdAt,
    };

WalletReadinessResponse _$WalletReadinessResponseFromJson(
        Map<String, dynamic> json) =>
    WalletReadinessResponse(
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
        WalletReadinessResponse instance) =>
    <String, dynamic>{
      'sufficient': instance.sufficient,
      'budget': instance.budget,
      'platformFee': instance.platformFee,
      'requiredTotal': instance.requiredTotal,
      'currentBalance': instance.currentBalance,
      'shortfall': instance.shortfall,
      'action': instance.action,
      'resumeFlow': instance.resumeFlow,
    };
