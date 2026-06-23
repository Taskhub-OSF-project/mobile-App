import 'package:json_annotation/json_annotation.dart';

part 'messaging_models.g.dart';

@JsonSerializable()
class ConversationResponse {
  final int id;
  @JsonKey(name: 'taskId')
  final int taskId;
  @JsonKey(name: 'taskTitle')
  final String? taskTitle;
  @JsonKey(name: 'participantAId')
  final int participantAId;
  @JsonKey(name: 'participantAName')
  final String? participantAName;
  @JsonKey(name: 'participantBId')
  final int participantBId;
  @JsonKey(name: 'participantBName')
  final String? participantBName;
  @JsonKey(name: 'otherUserId')
  final int? otherUserId;
  @JsonKey(name: 'otherUserName')
  final String? otherUserName;
  @JsonKey(name: 'lastMessagePreview')
  final String? lastMessagePreview;
  @JsonKey(name: 'lastMessageAt')
  final String? lastMessageAt;
  @JsonKey(name: 'unreadCount')
  final int unreadCount;
  @JsonKey(name: 'createdAt')
  final String createdAt;

  ConversationResponse({
    required this.id, required this.taskId, this.taskTitle,
    required this.participantAId, this.participantAName,
    required this.participantBId, this.participantBName,
    this.otherUserId, this.otherUserName, this.lastMessagePreview,
    this.lastMessageAt, required this.unreadCount, required this.createdAt,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationResponseToJson(this);
}

@JsonSerializable()
class MessageResponse {
  final int id;
  @JsonKey(name: 'conversationId')
  final int conversationId;
  @JsonKey(name: 'senderId')
  final int senderId;
  @JsonKey(name: 'senderName')
  final String senderName;
  final String content;
  @JsonKey(name: 'isRead')
  final bool? isRead;
  @JsonKey(name: 'readAt')
  final String? readAt;
  @JsonKey(name: 'createdAt')
  final String createdAt;

  MessageResponse({
    required this.id, required this.conversationId, required this.senderId,
    required this.senderName, required this.content, this.isRead,
    this.readAt, required this.createdAt,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
}

@JsonSerializable()
class SendMessageRequest {
  final String content;

  SendMessageRequest({required this.content});

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendMessageRequestToJson(this);
}
