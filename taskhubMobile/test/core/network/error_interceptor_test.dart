import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskhub_mobile/core/models/api_error.dart';
import 'package:taskhub_mobile/core/network/error_interceptor.dart';

class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  late ErrorInterceptor interceptor;
  late MockErrorInterceptorHandler mockHandler;

  setUpAll(() {
    registerFallbackValue(DioException(requestOptions: RequestOptions(path: '/')));
  });

  setUp(() {
    interceptor = ErrorInterceptor();
    mockHandler = MockErrorInterceptorHandler();
  });

  test('maps connectionTimeout to ApiError', () {
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.connectionTimeout,
    );

    interceptor.onError(dioError, mockHandler);

    final captured = verify(() => mockHandler.next(captureAny())).captured;
    final handledError = captured.first as DioException;
    
    expect(handledError.error, isA<ApiError>());
    expect((handledError.error as ApiError).message, contains('timeout'));
  });

  test('maps badResponse 404 to ApiError', () {
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/'),
        statusCode: 404,
      ),
    );

    interceptor.onError(dioError, mockHandler);

    final captured = verify(() => mockHandler.next(captureAny())).captured;
    final handledError = captured.first as DioException;
    
    expect(handledError.error, isA<ApiError>());
    expect((handledError.error as ApiError).statusCode, 404);
  });
}
