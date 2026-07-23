// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'momo_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MomoCreateOrderResponse _$MomoCreateOrderResponseFromJson(
        Map<String, dynamic> json) =>
    MomoCreateOrderResponse(
      orderId: json['orderId'] as String,
      deeplink: json['deeplink'] as String?,
      payUrl: json['payUrl'] as String?,
      qrCodeUrl: json['qrCodeUrl'] as String?,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$MomoCreateOrderResponseToJson(
        MomoCreateOrderResponse instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'deeplink': instance.deeplink,
      'payUrl': instance.payUrl,
      'qrCodeUrl': instance.qrCodeUrl,
      'amount': instance.amount,
      'status': instance.status,
      'message': instance.message,
    };

MomoWithdrawResponse _$MomoWithdrawResponseFromJson(
        Map<String, dynamic> json) =>
    MomoWithdrawResponse(
      orderId: json['orderId'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      newBalance: (json['newBalance'] as num?)?.toDouble(),
      message: json['message'] as String?,
      momoTransId: json['momoTransId'] as String?,
    );

Map<String, dynamic> _$MomoWithdrawResponseToJson(
        MomoWithdrawResponse instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'status': instance.status,
      'amount': instance.amount,
      'newBalance': instance.newBalance,
      'message': instance.message,
      'momoTransId': instance.momoTransId,
    };
