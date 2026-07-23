// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationResponse _$NotificationResponseFromJson(
  Map<String, dynamic> json,
) => NotificationResponse(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  isRead: json['isRead'] as bool?,
  readAt: json['readAt'] as String?,
  actionUrl: json['actionUrl'] as String?,
  taskId: (json['taskId'] as num?)?.toInt(),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$NotificationResponseToJson(
  NotificationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'title': instance.title,
  'message': instance.message,
  'isRead': instance.isRead,
  'readAt': instance.readAt,
  'actionUrl': instance.actionUrl,
  'taskId': instance.taskId,
  'createdAt': instance.createdAt,
};
