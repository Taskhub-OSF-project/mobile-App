// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileResponse _$UserProfileResponseFromJson(
  Map<String, dynamic> json,
) => UserProfileResponse(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  fullName: json['fullName'] as String,
  university: json['university'] as String?,
  major: json['major'] as String?,
  bio: json['bio'] as String?,
  skills: (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList(),
  experience: json['experience'] as String?,
  portfolioUrl: json['portfolioUrl'] as String?,
  phone: json['phone'] as String?,
  title: json['title'] as String?,
  hourlyRate: json['hourlyRate'] as String?,
  availability: json['availability'] as String?,
  languages: (json['languages'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  certifications: (json['certifications'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  avatarUrl: json['avatarUrl'] as String?,
  role: json['role'] as String?,
  walletBalance: json['walletBalance'] as num?,
  isVerified: json['isVerified'] as bool?,
  isAvailable: json['isAvailable'] as bool?,
  isBanned: json['isBanned'] as bool?,
  dateOfBirth: json['dateOfBirth'] as String?,
  age: (json['age'] as num?)?.toInt(),
  averageRatingAsFreelancer: json['averageRatingAsFreelancer'] as num?,
  averageRatingAsHirer: json['averageRatingAsHirer'] as num?,
  totalReviewsAsFreelancer: (json['totalReviewsAsFreelancer'] as num?)?.toInt(),
  totalReviewsAsHirer: (json['totalReviewsAsHirer'] as num?)?.toInt(),
  totalEarnings: json['totalEarnings'] as num?,
  completedTasksAsFreelancer: (json['completedTasksAsFreelancer'] as num?)
      ?.toInt(),
  completedTasksAsHirer: (json['completedTasksAsHirer'] as num?)?.toInt(),
  memberSince: json['memberSince'] as String?,
);

Map<String, dynamic> _$UserProfileResponseToJson(
  UserProfileResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'fullName': instance.fullName,
  'university': instance.university,
  'major': instance.major,
  'bio': instance.bio,
  'skills': instance.skills,
  'experience': instance.experience,
  'portfolioUrl': instance.portfolioUrl,
  'phone': instance.phone,
  'title': instance.title,
  'hourlyRate': instance.hourlyRate,
  'availability': instance.availability,
  'languages': instance.languages,
  'certifications': instance.certifications,
  'avatarUrl': instance.avatarUrl,
  'role': instance.role,
  'walletBalance': instance.walletBalance,
  'isVerified': instance.isVerified,
  'isAvailable': instance.isAvailable,
  'isBanned': instance.isBanned,
  'dateOfBirth': instance.dateOfBirth,
  'age': instance.age,
  'averageRatingAsFreelancer': instance.averageRatingAsFreelancer,
  'averageRatingAsHirer': instance.averageRatingAsHirer,
  'totalReviewsAsFreelancer': instance.totalReviewsAsFreelancer,
  'totalReviewsAsHirer': instance.totalReviewsAsHirer,
  'totalEarnings': instance.totalEarnings,
  'completedTasksAsFreelancer': instance.completedTasksAsFreelancer,
  'completedTasksAsHirer': instance.completedTasksAsHirer,
  'memberSince': instance.memberSince,
};

UserProfileUpdateRequest _$UserProfileUpdateRequestFromJson(
  Map<String, dynamic> json,
) => UserProfileUpdateRequest(
  fullName: json['fullName'] as String?,
  university: json['university'] as String?,
  school: json['school'] as String?,
  major: json['major'] as String?,
  bio: json['bio'] as String?,
  skills: (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList(),
  experience: json['experience'] as String?,
  portfolioUrl: json['portfolioUrl'] as String?,
  phone: json['phone'] as String?,
  title: json['title'] as String?,
  hourlyRate: json['hourlyRate'] as String?,
  availability: json['availability'] as String?,
  languages: (json['languages'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  certifications: (json['certifications'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  avatarUrl: json['avatarUrl'] as String?,
  dateOfBirth: json['dateOfBirth'] as String?,
);

Map<String, dynamic> _$UserProfileUpdateRequestToJson(
  UserProfileUpdateRequest instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'university': instance.university,
  'school': instance.school,
  'major': instance.major,
  'bio': instance.bio,
  'skills': instance.skills,
  'experience': instance.experience,
  'portfolioUrl': instance.portfolioUrl,
  'phone': instance.phone,
  'title': instance.title,
  'hourlyRate': instance.hourlyRate,
  'availability': instance.availability,
  'languages': instance.languages,
  'certifications': instance.certifications,
  'avatarUrl': instance.avatarUrl,
  'dateOfBirth': instance.dateOfBirth,
};
