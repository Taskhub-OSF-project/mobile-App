import 'package:dio/dio.dart';
import 'api_exception.dart';

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
      final data = _unwrapResponse<T>(response, parser);
      return Result.success(data);
    } on DioException catch (e) {
      return Result.failure(ApiException.fromDioError(e));
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
      final parsed = _unwrapResponse<T>(response, parser);
      return Result.success(parsed);
    } on DioException catch (e) {
      return Result.failure(ApiException.fromDioError(e));
    }
  }

  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      final parsed = _unwrapResponse<T>(response, parser);
      return Result.success(parsed);
    } on DioException catch (e) {
      return Result.failure(ApiException.fromDioError(e));
    }
  }

  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final response = await _dio.patch(path, data: data);
      final parsed = _unwrapResponse<T>(response, parser);
      return Result.success(parsed);
    } on DioException catch (e) {
      return Result.failure(ApiException.fromDioError(e));
    }
  }

  Future<Result<T>> delete<T>(
    String path, {
    T Function(dynamic json)? parser,
  }) async {
    try {
      final response = await _dio.delete(path);
      final parsed = _unwrapResponse<T>(response, parser);
      return Result.success(parsed);
    } on DioException catch (e) {
      return Result.failure(ApiException.fromDioError(e));
    }
  }

  T _unwrapResponse<T>(
    Response<dynamic> response,
    T Function(dynamic json)? parser,
  ) {
    if (parser != null) {
      return parser(response.data);
    }
    return response.data as T;
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
      final parsed = _unwrapResponse<T>(response, parser);
      return Result.success(parsed);
    } on DioException catch (e) {
      return Result.failure(ApiException.fromDioError(e));
    }
  }
}
