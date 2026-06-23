import 'package:json_annotation/json_annotation.dart';

part 'notification_models.g.dart';

@JsonSerializable()
class NotificationResponse {
  final int id;
  final String type;
  final String title;
  final String message;
  @JsonKey(name: 'isRead')
  final bool? isRead;
  @JsonKey(name: 'readAt')
  final String? readAt;
  @JsonKey(name: 'actionUrl')
  final String? actionUrl;
  @JsonKey(name: 'taskId')
  final int? taskId;
  @JsonKey(name: 'createdAt')
  final String createdAt;

  NotificationResponse({
    required this.id, required this.type, required this.title,
    required this.message, this.isRead, this.readAt,
    this.actionUrl, this.taskId, required this.createdAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}
