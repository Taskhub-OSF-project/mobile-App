// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewResponse _$ReviewResponseFromJson(Map<String, dynamic> json) =>
    ReviewResponse(
      id: (json['id'] as num).toInt(),
      taskId: (json['taskId'] as num).toInt(),
      taskTitle: json['taskTitle'] as String,
      reviewerId: (json['reviewerId'] as num).toInt(),
      reviewerName: json['reviewerName'] as String,
      reviewerAvatar: json['reviewerAvatar'] as String?,
      targetUserId: (json['targetUserId'] as num).toInt(),
      reviewType: json['reviewType'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$ReviewResponseToJson(ReviewResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'taskTitle': instance.taskTitle,
      'reviewerId': instance.reviewerId,
      'reviewerName': instance.reviewerName,
      'reviewerAvatar': instance.reviewerAvatar,
      'targetUserId': instance.targetUserId,
      'reviewType': instance.reviewType,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt,
    };

CreateReviewRequest _$CreateReviewRequestFromJson(Map<String, dynamic> json) =>
    CreateReviewRequest(
      taskId: (json['taskId'] as num).toInt(),
      targetUserId: (json['targetUserId'] as num).toInt(),
      reviewType: json['reviewType'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
    );

Map<String, dynamic> _$CreateReviewRequestToJson(
  CreateReviewRequest instance,
) => <String, dynamic>{
  'taskId': instance.taskId,
  'targetUserId': instance.targetUserId,
  'reviewType': instance.reviewType,
  'rating': instance.rating,
  'comment': instance.comment,
};
