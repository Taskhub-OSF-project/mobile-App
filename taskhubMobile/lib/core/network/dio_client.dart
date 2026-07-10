import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'auth_interceptor.dart';
import 'refresh_interceptor.dart';
import 'error_interceptor.dart';
import 'logging_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  
  dio.interceptors.addAll([
    AuthInterceptor(ref),
    RefreshInterceptor(ref),
    ErrorInterceptor(),
    LoggingInterceptor(),
  ]);
  
  return dio;
});
