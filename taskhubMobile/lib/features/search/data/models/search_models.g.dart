// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreelancerSearchResponse _$FreelancerSearchResponseFromJson(
  Map<String, dynamic> json,
) => FreelancerSearchResponse(
  id: (json['id'] as num).toInt(),
  fullName: json['fullName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  bio: json['bio'] as String?,
  skills:
      (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  completedTasks: (json['completedTasks'] as num?)?.toInt(),
  title: json['title'] as String?,
);

Map<String, dynamic> _$FreelancerSearchResponseToJson(
  FreelancerSearchResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'avatarUrl': instance.avatarUrl,
  'bio': instance.bio,
  'skills': instance.skills,
  'hourlyRate': instance.hourlyRate,
  'averageRating': instance.averageRating,
  'completedTasks': instance.completedTasks,
  'title': instance.title,
};
