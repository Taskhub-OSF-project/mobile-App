import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/api_error.dart';
import '../models/result.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _processResponse<T>(response, parser);
    } on DioException catch (e) {
      return Result.failure(_extractApiError(e));
    }
  }

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _processResponse<T>(response, parser);
    } on DioException catch (e) {
      return Result.failure(_extractApiError(e));
    }
  }

  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _processResponse<T>(response, parser);
    } on DioException catch (e) {
      return Result.failure(_extractApiError(e));
    }
  }

  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final response = await _dio.patch(path, data: data);
      return _processResponse<T>(response, parser);
    } on DioException catch (e) {
      return Result.failure(_extractApiError(e));
    }
  }

  Future<Result<T>> delete<T>(
    String path, {
    T Function(dynamic json)? parser,
  }) async {
    try {
      final response = await _dio.delete(path);
      return _processResponse<T>(response, parser);
    } on DioException catch (e) {
      return Result.failure(_extractApiError(e));
    }
  }

  Future<Result<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fileName,
    Map<String, dynamic>? extraData,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        if (extraData != null) ...extraData,
      });
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return _processResponse<T>(response, parser);
    } on DioException catch (e) {
      return Result.failure(_extractApiError(e));
    }
  }

  Result<T> _processResponse<T>(
    Response<dynamic> response,
    T Function(dynamic json)? parser,
  ) {
    if (response.data != null && response.data is Map<String, dynamic>) {
      final apiResponse = ApiResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        parser ?? (json) => json as T,
      );
      
      if (!apiResponse.success) {
        return Result.failure(ApiError(
          message: apiResponse.message ?? 'Operation failed',
          statusCode: response.statusCode,
          payload: response.data,
        ));
      }
      
      if (apiResponse.data == null && null is! T) {
         return Result.failure(ApiError(message: 'Null data returned but expected a value'));
      }
      return Result.success(apiResponse.data as T);
    }
    
    return Result.failure(ApiError(message: 'Invalid response format'));
  }
  
  ApiError _extractApiError(DioException e) {
    if (e.error is ApiError) {
      return e.error as ApiError;
    }
    return ApiError(
      statusCode: e.response?.statusCode,
      message: e.message ?? 'Unknown network error',
    );
  }
}
