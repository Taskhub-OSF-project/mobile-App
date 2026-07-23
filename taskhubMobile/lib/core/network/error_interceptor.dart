import 'dart:io';
import 'package:dio/dio.dart';
import '../models/api_error.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is ApiError) {
      return handler.next(err);
    }

    ApiError apiError;
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        apiError = ApiError(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: err.response?.statusCode,
        );
        break;
      case DioExceptionType.badResponse:
        apiError = _handleResponseError(err.response);
        break;
      case DioExceptionType.cancel:
        apiError = ApiError(message: 'Request was cancelled');
        break;
      case DioExceptionType.connectionError:
        apiError = ApiError(message: 'No internet connection');
        break;
      case DioExceptionType.unknown:
      default:
        if (err.error is SocketException) {
          apiError = ApiError(message: 'No internet connection');
        } else {
          apiError = ApiError(
            message: err.message ?? 'An unexpected error occurred',
            statusCode: err.response?.statusCode,
          );
        }
        break;
    }

    final newErr = err.copyWith(error: apiError);
    return handler.next(newErr);
  }

  ApiError _handleResponseError(Response? response) {
    if (response == null) {
      return ApiError(message: 'Server error, please try again later');
    }
    
    final statusCode = response.statusCode;
    
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('message') && map['success'] == false) {
        return ApiError(
          statusCode: statusCode,
          message: map['message']?.toString() ?? 'Lỗi không xác định',
          payload: map,
        );
      }
    }
    
    switch (statusCode) {
      case 401:
        return AuthExpiredError();
      case 403:
        return ApiError(statusCode: 403, message: 'Insufficient permissions');
      case 404:
        return ApiError(statusCode: 404, message: 'Resource not found');
      case 422:
        return ApiError(statusCode: 422, message: 'Validation error', payload: response.data);
      case 429:
        return ApiError(statusCode: 429, message: 'Too many requests, please wait');
      case 500:
      case 502:
      case 503:
      case 504:
        return ApiError(statusCode: statusCode, message: 'Server error, please try again later');
      default:
        return ApiError(statusCode: statusCode, message: 'Unexpected error occurred');
    }
  }
}
