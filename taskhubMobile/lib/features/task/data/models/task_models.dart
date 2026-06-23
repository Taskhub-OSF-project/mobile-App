import 'package:json_annotation/json_annotation.dart';

part 'task_models.g.dart';

enum TaskStatus {
  DRAFT, LOCKED, ESCROW_FUNDED, ACTIVE, IN_PROGRESS, SUBMITTED, COMPLETED, DISPUTED
}

@JsonSerializable()
class CriteriaResponse {
  final int id;
  final String description;
  final String? status;

  CriteriaResponse({required this.id, required this.description, this.status});

  factory CriteriaResponse.fromJson(Map<String, dynamic> json) =>
      _$CriteriaResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CriteriaResponseToJson(this);
}

@JsonSerializable()
class ApplicationResponse {
  final int id;
  @JsonKey(name: 'taskId')
  final int taskId;
  @JsonKey(name: 'studentId')
  final int studentId;
  @JsonKey(name: 'studentName')
  final String studentName;
  @JsonKey(name: 'studentUniversity')
  final String? studentUniversity;
  @JsonKey(name: 'studentMajor')
  final String? studentMajor;
  @JsonKey(name: 'coverLetter')
  final String? coverLetter;
  final String? status;
  @JsonKey(name: 'appliedAt')
  final String appliedAt;

  ApplicationResponse({
    required this.id, required this.taskId, required this.studentId,
    required this.studentName, this.studentUniversity, this.studentMajor,
    this.coverLetter, this.status, required this.appliedAt,
  });

  factory ApplicationResponse.fromJson(Map<String, dynamic> json) =>
      _$ApplicationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationResponseToJson(this);
}

@JsonSerializable()
class TaskResponse {
  final int id;
  final String title;
  final String description;
  final String? category;
  final double budget;
  final String? deadline;
  final String? status;
  @JsonKey(name: 'hirerId')
  final int hirerId;
  @JsonKey(name: 'hirerName')
  final String hirerName;
  @JsonKey(name: 'assignedToId')
  final int? assignedToId;
  @JsonKey(name: 'assignedToName')
  final String? assignedToName;
  @JsonKey(name: 'revisionCount')
  final int? revisionCount;
  @JsonKey(name: 'acceptanceCriteria')
  final List<CriteriaResponse>? acceptanceCriteria;
  @JsonKey(name: 'applicants')
  final List<ApplicationResponse>? applicants;
  @JsonKey(name: 'createdAt')
  final String createdAt;

  TaskResponse({
    required this.id, required this.title, required this.description,
    this.category, required this.budget, this.deadline, this.status,
    required this.hirerId, required this.hirerName, this.assignedToId,
    this.assignedToName, this.revisionCount, this.acceptanceCriteria,
    this.applicants, required this.createdAt,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TaskResponseToJson(this);

  TaskStatus get statusEnum {
    if (status == null) return TaskStatus.DRAFT;
    return TaskStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TaskStatus.DRAFT,
    );
  }

  bool get isDeletable => status == 'DRAFT' || status == 'LOCKED';
}

@JsonSerializable()
class CreateTaskRequest {
  final String title;
  final String description;
  final String? category;
  final double budget;
  final String deadline;
  @JsonKey(name: 'acceptanceCriteria')
  final List<String> acceptanceCriteria;

  CreateTaskRequest({
    required this.title, required this.description, this.category,
    required this.budget, required this.deadline, required this.acceptanceCriteria,
  });

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTaskRequestToJson(this);
}

@JsonSerializable()
class PatchTaskRequest {
  final String? title;
  final String? description;
  final String? category;
  final double? budget;
  final String? deadline;
  @JsonKey(name: 'acceptanceCriteria')
  final List<String>? acceptanceCriteria;

  PatchTaskRequest({
    this.title, this.description, this.category, this.budget,
    this.deadline, this.acceptanceCriteria,
  });

  factory PatchTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PatchTaskRequestToJson(this);
}

@JsonSerializable()
class ApplicationRequest {
  @JsonKey(name: 'coverLetter')
  final String? coverLetter;

  ApplicationRequest({this.coverLetter});

  factory ApplicationRequest.fromJson(Map<String, dynamic> json) =>
      _$ApplicationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationRequestToJson(this);
}

@JsonSerializable()
class DisputeRequest {
  final String reason;
  final String? description;

  DisputeRequest({required this.reason, this.description});

  factory DisputeRequest.fromJson(Map<String, dynamic> json) =>
      _$DisputeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DisputeRequestToJson(this);
}

@JsonSerializable()
class DisputeResolveRequest {
  final String action;

  DisputeResolveRequest({required this.action});

  factory DisputeResolveRequest.fromJson(Map<String, dynamic> json) =>
      _$DisputeResolveRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DisputeResolveRequestToJson(this);
}

@JsonSerializable()
class SubmittedFileDto {
  @JsonKey(name: 'fileName')
  final String fileName;
  final String path;
  final String? url;
  @JsonKey(name: 'contentType')
  final String? contentType;
  final int? size;
  final String? uploadedAt;

  SubmittedFileDto({
    required this.fileName, required this.path, this.url,
    this.contentType, this.size, this.uploadedAt,
  });

  factory SubmittedFileDto.fromJson(Map<String, dynamic> json) =>
      _$SubmittedFileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubmittedFileDtoToJson(this);
}

@JsonSerializable()
class SubmissionRequest {
  @JsonKey(name: 'fileUrl')
  final String? fileUrl;
  final String? notes;
  @JsonKey(name: 'submittedFiles')
  final List<SubmittedFileDto>? submittedFiles;

  SubmissionRequest({
    this.fileUrl, this.notes, this.submittedFiles,
  });

  factory SubmissionRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmissionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmissionRequestToJson(this);
}

@JsonSerializable()
class RevisionRequestDto {
  final String reason;
  final String? description;

  RevisionRequestDto({required this.reason, this.description});

  factory RevisionRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RevisionRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RevisionRequestDtoToJson(this);
}
