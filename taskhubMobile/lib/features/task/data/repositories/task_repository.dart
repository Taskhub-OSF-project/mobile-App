import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/models/result.dart';
import 'package:taskhub_mobile/core/models/page_response.dart';
import '../models/task_models.dart';

class TaskRepository {
  final ApiService _api;

  TaskRepository(this._api);

  Future<Result<TaskResponse>> getTask(int id) async {
    final response = await _api.get<TaskResponse>(
      ApiConstants.taskById(id),
      parser: (json) =>
          TaskResponse.fromJson(json as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<PageResponse<TaskResponse>>> getMyTasks({
    String? status,
    int page = 0,
    int size = 20,
    String sortBy = 'id',
    String sortDir = 'desc',
  }) async {
    final response = await _api.get<PageResponse<TaskResponse>>(
      ApiConstants.myTasks,
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'size': size,
        'sortBy': sortBy,
        'sortDir': sortDir,
      },
      parser: (json) => PageResponse<TaskResponse>.fromJson(
        json as Map<String, dynamic>,
        (e) => TaskResponse.fromJson(e as Map<String, dynamic>),
      ),
    );
    return response;
  }

  Future<Result<PageResponse<TaskResponse>>> getAvailableTasks({
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    final response = await _api.get<PageResponse<TaskResponse>>(
      ApiConstants.availableTasks,
      queryParameters: {
        'page': page,
        'size': size,
        'sortBy': sortBy,
        'sortDir': sortDir,
      },
      parser: (json) => PageResponse<TaskResponse>.fromJson(
        json as Map<String, dynamic>,
        (e) => TaskResponse.fromJson(e as Map<String, dynamic>),
      ),
    );
    return response;
  }

  Future<Result<TaskResponse>> createTask(CreateTaskRequest request) async {
    final response = await _api.post<TaskResponse>(
      ApiConstants.tasks,
      data: request.toJson(),
      parser: (json) =>
          TaskResponse.fromJson(json as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<TaskResponse>> updateTask(int id, PatchTaskRequest request) async {
    final response = await _api.patch<TaskResponse>(
      ApiConstants.patchTask(id),
      data: request.toJson(),
      parser: (json) =>
          TaskResponse.fromJson(json as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<void>> deleteTask(int id) async {
    return _api.delete<void>(ApiConstants.deleteTask(id));
  }

  Future<Result<TaskResponse>> lockTask(int id) async {
    final response = await _api.post<TaskResponse>(
      ApiConstants.lockTask(id),
      parser: (json) =>
          TaskResponse.fromJson(json as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<TaskResponse>> publishTask(int id) async {
    final response = await _api.post<TaskResponse>(
      ApiConstants.publishTask(id),
      parser: (json) =>
          TaskResponse.fromJson(json as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<TaskResponse>> completeTask(int id) async {
    final response = await _api.post<TaskResponse>(
      ApiConstants.completeTask(id),
      parser: (json) =>
          TaskResponse.fromJson(json as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<void>> fundEscrow(int taskId) async {
    return _api.post<void>(ApiConstants.fundEscrow(taskId));
  }

  Future<Result<void>> releaseEscrow(int taskId) async {
    return _api.post<void>(ApiConstants.releaseEscrow(taskId));
  }

  Future<Result<void>> refundEscrow(int taskId) async {
    return _api.post<void>(ApiConstants.refundEscrow(taskId));
  }

  Future<Result<ApplicationResponse>> applyToTask(
      int taskId, String? coverLetter) async {
    final response = await _api.post<ApplicationResponse>(
      ApiConstants.applyToTask(taskId),
      data: {'coverLetter': coverLetter},
      parser: (json) =>
          ApplicationResponse.fromJson(json as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<void>> acceptApplication(int applicationId) async {
    return _api.post<void>(ApiConstants.acceptApplication(applicationId));
  }

  Future<Result<PageResponse<ApplicationResponse>>> getTaskApplications(
    int taskId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _api.get<PageResponse<ApplicationResponse>>(
      ApiConstants.taskApplications(taskId),
      queryParameters: {'page': page, 'size': size},
      parser: (json) => PageResponse<ApplicationResponse>.fromJson(
        json as Map<String, dynamic>,
        (e) => ApplicationResponse.fromJson(e as Map<String, dynamic>),
      ),
    );
    return response;
  }

  Future<Result<PageResponse<ApplicationResponse>>> getMyApplications({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _api.get<PageResponse<ApplicationResponse>>(
      ApiConstants.myApplications,
      queryParameters: {'page': page, 'size': size},
      parser: (json) => PageResponse<ApplicationResponse>.fromJson(
        json as Map<String, dynamic>,
        (e) => ApplicationResponse.fromJson(e as Map<String, dynamic>),
      ),
    );
    return response;
  }

  Future<Result<SubmissionResponse>> submitWork(
      int taskId, String? notes, List<String>? fileUrls) async {
    return _api.post<SubmissionResponse>(
      ApiConstants.submitTask(taskId),
      data: {
        'notes': notes,
        if (fileUrls != null) 'fileUrl': fileUrls.join(','),
      },
      parser: (json) =>
          SubmissionResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<LatestSubmissionResultResponse>> getLatestSubmission(int taskId) async {
    return _api.get<LatestSubmissionResultResponse>(
      '${ApiConstants.submitTask(taskId)}/latest',
      parser: (json) => LatestSubmissionResultResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<SubmissionAIResult>> precheckSubmission(int taskId, SubmissionRequest request) async {
    return _api.post<SubmissionAIResult>(
      '${ApiConstants.submitTask(taskId)}/precheck',
      data: request.toJson(),
      parser: (json) => SubmissionAIResult.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<void>> requestRevision(int taskId, String reason,
      {String? description}) async {
    return _api.post<void>(
      ApiConstants.requestRevision(taskId),
      data: {
        'reason': reason,
        if (description != null) 'description': description,
      },
    );
  }

  Future<Result<void>> approveSubmission(int taskId) async {
    return _api.post<void>(ApiConstants.approveSubmission(taskId));
  }

  Future<Result<void>> disputeTask(int taskId, String reason,
      {String? description}) async {
    return _api.post<void>(
      ApiConstants.disputeTask(taskId),
      data: {
        'reason': reason,
        if (description != null) 'description': description,
      },
    );
  }
}
