// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging_models.dart';

ConversationResponse _$ConversationResponseFromJson(Map<String, dynamic> json) =>
    ConversationResponse(
      id: (json['id'] as num).toInt(),
      taskId: (json['taskId'] as num).toInt(),
      taskTitle: json['taskTitle'] as String?,
      participantAId: (json['participantAId'] as num).toInt(),
      participantAName: json['participantAName'] as String?,
      participantBId: (json['participantBId'] as num).toInt(),
      participantBName: json['participantBName'] as String?,
      otherUserId: (json['otherUserId'] as num?)?.toInt(),
      otherUserName: json['otherUserName'] as String?,
      lastMessagePreview: json['lastMessagePreview'] as String?,
      lastMessageAt: json['lastMessageAt'] as String?,
      unreadCount: (json['unreadCount'] as num).toInt(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$ConversationResponseToJson(
        ConversationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'taskTitle': instance.taskTitle,
      'participantAId': instance.participantAId,
      'participantAName': instance.participantAName,
      'participantBId': instance.participantBId,
      'participantBName': instance.participantBName,
      'otherUserId': instance.otherUserId,
      'otherUserName': instance.otherUserName,
      'lastMessagePreview': instance.lastMessagePreview,
      'lastMessageAt': instance.lastMessageAt,
      'unreadCount': instance.unreadCount,
      'createdAt': instance.createdAt,
    };

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      id: (json['id'] as num).toInt(),
      conversationId: (json['conversationId'] as num).toInt(),
      senderId: (json['senderId'] as num).toInt(),
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      isRead: json['isRead'] as bool?,
      readAt: json['readAt'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'content': instance.content,
      'isRead': instance.isRead,
      'readAt': instance.readAt,
      'createdAt': instance.createdAt,
    };

SendMessageRequest _$SendMessageRequestFromJson(Map<String, dynamic> json) =>
    SendMessageRequest(
      content: json['content'] as String,
    );

Map<String, dynamic> _$SendMessageRequestToJson(SendMessageRequest instance) =>
    <String, dynamic>{
      'content': instance.content,
    };
