import 'package:json_annotation/json_annotation.dart';
import '../../../../core/models/page_response.dart';

part 'search_models.g.dart';

@JsonSerializable(explicitToJson: true)
class FreelancerSearchResponse {
  final int id;
  final String fullName;
  final String? avatarUrl;
  final String? bio;
  final List<String> skills;
  final double? hourlyRate;
  final double? averageRating;
  final int? completedTasks;
  final String? title;

  FreelancerSearchResponse({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    this.skills = const [],
    this.hourlyRate,
    this.averageRating,
    this.completedTasks,
    this.title,
  });

  factory FreelancerSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$FreelancerSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FreelancerSearchResponseToJson(this);
}
