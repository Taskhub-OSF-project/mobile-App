import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException err) {
    String message;
    int? statusCode = err.response?.statusCode;
    String? errorCode;
    dynamic data;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server took too long to respond.';
        break;
      case DioExceptionType.badResponse:
        final body = err.response?.data;
        if (body is Map) {
          message = body['message'] as String? ?? 'An error occurred';
          errorCode = body['errorCode'] as String?;
          data = body['data'];
        } else {
          message = 'Server error: ${err.response?.statusCode}';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection.';
        break;
      default:
        message = err.message ?? 'An unexpected error occurred.';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      data: data,
    );
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() => 'ApiException: $message (status: $statusCode, code: $errorCode)';
}

class Result<T> {
  final T? _data;
  final ApiException? _error;

  Result._({T? data, ApiException? error})
      : _data = data,
        _error = error;

  factory Result.success(T data) => Result._(data: data);
  factory Result.failure(ApiException error) => Result._(error: error);

  bool get isSuccess => _data != null;
  bool get isFailure => _error != null;
  T? get data => _data;
  ApiException? get error => _error;

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiException error) failure,
  }) {
    if (_data != null) return success(_data as T);
    return failure(_error!);
  }
}

extension ResultExtension<T> on Result<T> {
  T? getOrNull() => _data;
  T getOrThrow() {
    if (_data != null) return _data as T;
    throw _error ?? Exception('No data');
  }
}
