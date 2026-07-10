import 'package:json_annotation/json_annotation.dart';

part 'review_models.g.dart';

@JsonSerializable(explicitToJson: true)
class ReviewResponse {
  final int id;
  final int taskId;
  final String taskTitle;
  final int reviewerId;
  final String reviewerName;
  final String? reviewerAvatar;
  final int targetUserId;
  final String reviewType;
  final double rating;
  final String comment;
  final String createdAt;

  ReviewResponse({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerAvatar,
    required this.targetUserId,
    required this.reviewType,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$ReviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateReviewRequest {
  final int taskId;
  final int targetUserId;
  final String reviewType;
  final double rating;
  final String comment;

  CreateReviewRequest({
    required this.taskId,
    required this.targetUserId,
    required this.reviewType,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() => _$CreateReviewRequestToJson(this);
}
