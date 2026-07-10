import 'dart:developer';
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('=> ${options.method} ${options.uri}', name: 'DIO');
    log('Headers: ${options.headers}', name: 'DIO');
    if (options.data != null) {
      log('Body: ${options.data}', name: 'DIO');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('<= ${response.statusCode} ${response.requestOptions.uri}', name: 'DIO');
    if (response.data != null) {
      log('Response: ${response.data}', name: 'DIO');
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('<= ERROR ${err.response?.statusCode} ${err.requestOptions.uri}', name: 'DIO');
    log('Message: ${err.message}', name: 'DIO');
    if (err.response?.data != null) {
      log('Error Data: ${err.response?.data}', name: 'DIO');
    }
    return handler.next(err);
  }
}
