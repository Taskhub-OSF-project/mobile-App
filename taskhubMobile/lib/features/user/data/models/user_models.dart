import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

@JsonSerializable()
class UserProfileResponse {
  final int id;
  final String email;
  @JsonKey(name: 'fullName')
  final String fullName;
  final String? university;
  final String? major;
  final String? bio;
  final List<String>? skills;
  final String? experience;
  @JsonKey(name: 'portfolioUrl')
  final String? portfolioUrl;
  final String? phone;
  final String? title;
  @JsonKey(name: 'hourlyRate')
  final String? hourlyRate;
  final String? availability;
  final List<String>? languages;
  final List<String>? certifications;
  @JsonKey(name: 'avatarUrl')
  final String? avatarUrl;
  final String? role;
  @JsonKey(name: 'walletBalance')
  final double? walletBalance;
  @JsonKey(name: 'isVerified')
  final bool? isVerified;
  @JsonKey(name: 'isAvailable')
  final bool? isAvailable;
  @JsonKey(name: 'isBanned')
  final bool? isBanned;
  @JsonKey(name: 'averageRatingAsFreelancer')
  final double? averageRatingAsFreelancer;
  @JsonKey(name: 'averageRatingAsHirer')
  final double? averageRatingAsHirer;
  @JsonKey(name: 'totalReviewsAsFreelancer')
  final int? totalReviewsAsFreelancer;
  @JsonKey(name: 'totalReviewsAsHirer')
  final int? totalReviewsAsHirer;
  @JsonKey(name: 'totalEarnings')
  final double? totalEarnings;
  @JsonKey(name: 'completedTasksAsFreelancer')
  final int? completedTasksAsFreelancer;
  @JsonKey(name: 'completedTasksAsHirer')
  final int? completedTasksAsHirer;
  @JsonKey(name: 'memberSince')
  final String? memberSince;

  UserProfileResponse({
    required this.id,
    required this.email,
    required this.fullName,
    this.university,
    this.major,
    this.bio,
    this.skills,
    this.experience,
    this.portfolioUrl,
    this.phone,
    this.title,
    this.hourlyRate,
    this.availability,
    this.languages,
    this.certifications,
    this.avatarUrl,
    this.role,
    this.walletBalance,
    this.isVerified,
    this.isAvailable,
    this.isBanned,
    this.averageRatingAsFreelancer,
    this.averageRatingAsHirer,
    this.totalReviewsAsFreelancer,
    this.totalReviewsAsHirer,
    this.totalEarnings,
    this.completedTasksAsFreelancer,
    this.completedTasksAsHirer,
    this.memberSince,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UserProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileResponseToJson(this);

  bool get isHirer => role == 'HIRER';
  bool get isStudent => role == 'STUDENT';
  bool get isAdmin => role == 'ADMIN';
}

@JsonSerializable()
class UserProfileUpdateRequest {
  @JsonKey(name: 'fullName')
  final String? fullName;
  final String? university;
  final String? school;
  final String? major;
  final String? bio;
  final List<String>? skills;
  final String? experience;
  @JsonKey(name: 'portfolioUrl')
  final String? portfolioUrl;
  final String? phone;
  final String? title;
  @JsonKey(name: 'hourlyRate')
  final String? hourlyRate;
  final String? availability;
  final List<String>? languages;
  final List<String>? certifications;
  @JsonKey(name: 'avatarUrl')
  final String? avatarUrl;

  UserProfileUpdateRequest({
    this.fullName,
    this.university,
    this.school,
    this.major,
    this.bio,
    this.skills,
    this.experience,
    this.portfolioUrl,
    this.phone,
    this.title,
    this.hourlyRate,
    this.availability,
    this.languages,
    this.certifications,
    this.avatarUrl,
  });

  factory UserProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$UserProfileUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileUpdateRequestToJson(this);
}
