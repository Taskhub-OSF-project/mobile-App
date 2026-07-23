// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CriteriaResponse _$CriteriaResponseFromJson(Map<String, dynamic> json) =>
    CriteriaResponse(
      id: (json['id'] as num).toInt(),
      description: json['description'] as String,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$CriteriaResponseToJson(CriteriaResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'status': instance.status,
    };

ApplicationResponse _$ApplicationResponseFromJson(Map<String, dynamic> json) =>
    ApplicationResponse(
      id: (json['id'] as num).toInt(),
      taskId: (json['taskId'] as num).toInt(),
      studentId: (json['studentId'] as num).toInt(),
      studentName: json['studentName']?.toString() ?? '',
      studentUniversity: json['studentUniversity'] as String?,
      studentMajor: json['studentMajor'] as String?,
      coverLetter: json['coverLetter'] as String?,
      status: json['status'] as String?,
      appliedAt: json['appliedAt']?.toString() ?? '',
    );

Map<String, dynamic> _$ApplicationResponseToJson(
  ApplicationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'taskId': instance.taskId,
  'studentId': instance.studentId,
  'studentName': instance.studentName,
  'studentUniversity': instance.studentUniversity,
  'studentMajor': instance.studentMajor,
  'coverLetter': instance.coverLetter,
  'status': instance.status,
  'appliedAt': instance.appliedAt,
};

TaskResponse _$TaskResponseFromJson(Map<String, dynamic> json) => TaskResponse(
  id: (json['id'] as num).toInt(),
  title: json['title']?.toString() ?? '',
  description: json['description']?.toString() ?? '',
  category: json['category'] as String?,
  budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
  deadline: json['deadline'] as String?,
  status: json['status'] as String?,
  hirerId: (json['hirerId'] as num?)?.toInt() ?? 0,
  hirerName: json['hirerName']?.toString() ?? '',
  assignedToId: (json['assignedToId'] as num?)?.toInt(),
  assignedToName: json['assignedToName'] as String?,
  revisionCount: (json['revisionCount'] as num?)?.toInt(),
  acceptanceCriteria: (json['acceptanceCriteria'] as List<dynamic>?)
      ?.map((e) => CriteriaResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  applicants: (json['applicants'] as List<dynamic>?)
      ?.map((e) => ApplicationResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt']?.toString() ?? '',
);

Map<String, dynamic> _$TaskResponseToJson(TaskResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'budget': instance.budget,
      'deadline': instance.deadline,
      'status': instance.status,
      'hirerId': instance.hirerId,
      'hirerName': instance.hirerName,
      'assignedToId': instance.assignedToId,
      'assignedToName': instance.assignedToName,
      'revisionCount': instance.revisionCount,
      'acceptanceCriteria': instance.acceptanceCriteria,
      'applicants': instance.applicants,
      'createdAt': instance.createdAt,
    };

CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) =>
    CreateTaskRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String?,
      budget: (json['budget'] as num).toDouble(),
      deadline: json['deadline'] as String,
      acceptanceCriteria: (json['acceptanceCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CreateTaskRequestToJson(CreateTaskRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'budget': instance.budget,
      'deadline': instance.deadline,
      'acceptanceCriteria': instance.acceptanceCriteria,
    };

PatchTaskRequest _$PatchTaskRequestFromJson(Map<String, dynamic> json) =>
    PatchTaskRequest(
      title: json['title'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      deadline: json['deadline'] as String?,
      acceptanceCriteria: (json['acceptanceCriteria'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PatchTaskRequestToJson(PatchTaskRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'budget': instance.budget,
      'deadline': instance.deadline,
      'acceptanceCriteria': instance.acceptanceCriteria,
    };

ApplicationRequest _$ApplicationRequestFromJson(Map<String, dynamic> json) =>
    ApplicationRequest(coverLetter: json['coverLetter'] as String?);

Map<String, dynamic> _$ApplicationRequestToJson(ApplicationRequest instance) =>
    <String, dynamic>{'coverLetter': instance.coverLetter};

DisputeRequest _$DisputeRequestFromJson(Map<String, dynamic> json) =>
    DisputeRequest(
      reason: json['reason'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$DisputeRequestToJson(DisputeRequest instance) =>
    <String, dynamic>{
      'reason': instance.reason,
      'description': instance.description,
    };

DisputeResolveRequest _$DisputeResolveRequestFromJson(
  Map<String, dynamic> json,
) => DisputeResolveRequest(action: json['action'] as String);

Map<String, dynamic> _$DisputeResolveRequestToJson(
  DisputeResolveRequest instance,
) => <String, dynamic>{'action': instance.action};

SubmittedFileDto _$SubmittedFileDtoFromJson(Map<String, dynamic> json) =>
    SubmittedFileDto(
      fileName: json['fileName'] as String,
      path: json['path'] as String,
      url: json['url'] as String?,
      contentType: json['contentType'] as String?,
      size: (json['size'] as num?)?.toInt(),
      uploadedAt: json['uploadedAt'] as String?,
    );

Map<String, dynamic> _$SubmittedFileDtoToJson(SubmittedFileDto instance) =>
    <String, dynamic>{
      'fileName': instance.fileName,
      'path': instance.path,
      'url': instance.url,
      'contentType': instance.contentType,
      'size': instance.size,
      'uploadedAt': instance.uploadedAt,
    };

SubmissionRequest _$SubmissionRequestFromJson(Map<String, dynamic> json) =>
    SubmissionRequest(
      fileUrl: json['fileUrl'] as String?,
      notes: json['notes'] as String?,
      submittedFiles: (json['submittedFiles'] as List<dynamic>?)
          ?.map((e) => SubmittedFileDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubmissionRequestToJson(SubmissionRequest instance) =>
    <String, dynamic>{
      'fileUrl': instance.fileUrl,
      'notes': instance.notes,
      'submittedFiles': instance.submittedFiles,
    };

RevisionRequestDto _$RevisionRequestDtoFromJson(Map<String, dynamic> json) =>
    RevisionRequestDto(
      reason: json['reason'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$RevisionRequestDtoToJson(RevisionRequestDto instance) =>
    <String, dynamic>{
      'reason': instance.reason,
      'description': instance.description,
    };

SubmissionResponse _$SubmissionResponseFromJson(Map<String, dynamic> json) =>
    SubmissionResponse(
      id: (json['id'] as num).toInt(),
      taskId: (json['taskId'] as num).toInt(),
      studentId: (json['studentId'] as num).toInt(),
      fileUrl: json['fileUrl'] as String?,
      notes: json['notes'] as String?,
      submittedFiles: (json['submittedFiles'] as List<dynamic>?)
          ?.map((e) => SubmittedFileDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      submittedAt: json['submittedAt']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );

Map<String, dynamic> _$SubmissionResponseToJson(SubmissionResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'studentId': instance.studentId,
      'fileUrl': instance.fileUrl,
      'notes': instance.notes,
      'submittedFiles': instance.submittedFiles,
      'submittedAt': instance.submittedAt,
      'status': instance.status,
    };

CriteriaAIResult _$CriteriaAIResultFromJson(Map<String, dynamic> json) =>
    CriteriaAIResult(
      index: (json['index'] as num?)?.toInt(),
      criteria: json['criteria'] as String?,
      status: json['status'] as String?,
      locked: json['locked'] as bool?,
      evidence: json['evidence'] as String?,
      suggestion: json['suggestion'] as String?,
    );

Map<String, dynamic> _$CriteriaAIResultToJson(CriteriaAIResult instance) =>
    <String, dynamic>{
      'index': instance.index,
      'criteria': instance.criteria,
      'status': instance.status,
      'locked': instance.locked,
      'evidence': instance.evidence,
      'suggestion': instance.suggestion,
    };

SubmissionAIResult _$SubmissionAIResultFromJson(Map<String, dynamic> json) =>
    SubmissionAIResult(
      overallStatus: json['overallStatus'] as String?,
      criteriaResults: (json['criteriaResults'] as List<dynamic>?)
          ?.map((e) => CriteriaAIResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      canSubmit: json['canSubmit'] == true,
      evaluatedAt: json['evaluatedAt']?.toString(),
      summary: json['summary']?.toString(),
    );

Map<String, dynamic> _$SubmissionAIResultToJson(SubmissionAIResult instance) =>
    <String, dynamic>{
      'overallStatus': instance.overallStatus,
      'criteriaResults': instance.criteriaResults,
      'canSubmit': instance.canSubmit,
      'evaluatedAt': instance.evaluatedAt,
      'summary': instance.summary,
    };

PublicTaskResponse _$PublicTaskResponseFromJson(Map<String, dynamic> json) =>
    PublicTaskResponse(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String?,
      budget: json['budget'] as String,
      deadline: json['deadline'] as String?,
      status: json['status'] as String?,
      hirerName: json['hirerName'] as String?,
      hirerId: (json['hirerId'] as num?)?.toInt(),
      hirerAvatarUrl: json['hirerAvatarUrl'] as String?,
      skillsRequired: (json['skillsRequired'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      applicantCount: (json['applicantCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$PublicTaskResponseToJson(PublicTaskResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'budget': instance.budget,
      'deadline': instance.deadline,
      'status': instance.status,
      'hirerName': instance.hirerName,
      'hirerId': instance.hirerId,
      'hirerAvatarUrl': instance.hirerAvatarUrl,
      'skillsRequired': instance.skillsRequired,
      'applicantCount': instance.applicantCount,
      'createdAt': instance.createdAt,
    };

RevisionRequestResponse _$RevisionRequestResponseFromJson(
  Map<String, dynamic> json,
) => RevisionRequestResponse(
  id: (json['id'] as num).toInt(),
  taskId: (json['taskId'] as num).toInt(),
  reason: json['reason'] as String,
  description: json['description'] as String?,
  requestedAt: json['requestedAt'] as String,
);

Map<String, dynamic> _$RevisionRequestResponseToJson(
  RevisionRequestResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'taskId': instance.taskId,
  'reason': instance.reason,
  'description': instance.description,
  'requestedAt': instance.requestedAt,
};

LatestSubmissionResultResponse _$LatestSubmissionResultResponseFromJson(
  Map<String, dynamic> json,
) => LatestSubmissionResultResponse(
  submission: json['submission'] == null
      ? null
      : SubmissionResponse.fromJson(json['submission'] as Map<String, dynamic>),
  aiResult: json['aiResult'] == null
      ? null
      : SubmissionAIResult.fromJson(json['aiResult'] as Map<String, dynamic>),
  revisions: (json['revisions'] as List<dynamic>?)
      ?.map((e) => RevisionRequestResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LatestSubmissionResultResponseToJson(
  LatestSubmissionResultResponse instance,
) => <String, dynamic>{
  'submission': instance.submission,
  'aiResult': instance.aiResult,
  'revisions': instance.revisions,
};
