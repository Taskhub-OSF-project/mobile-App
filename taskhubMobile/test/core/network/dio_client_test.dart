import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskhub_mobile/core/network/refresh_interceptor.dart';
import 'package:taskhub_mobile/core/storage/secure_storage_service.dart';
import 'package:taskhub_mobile/providers.dart';

class MockSecureStorage extends Mock implements SecureStorageService {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

class MockRef extends Mock implements Ref {}

void main() {
  late MockSecureStorage mockStorage;
  late MockRef mockRef;
  late RefreshInterceptor interceptor;
  late MockErrorInterceptorHandler mockHandler;

  setUpAll(() {
    registerFallbackValue(DioException(requestOptions: RequestOptions(path: '/')));
  });

  setUp(() {
    mockStorage = MockSecureStorage();
    mockRef = MockRef();
    when(() => mockRef.read(secureStorageProvider)).thenReturn(mockStorage);
    
    interceptor = RefreshInterceptor(mockRef);
    mockHandler = MockErrorInterceptorHandler();
  });

  test('ignores non-401 errors', () async {
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/api/tasks'),
      response: Response(
        requestOptions: RequestOptions(path: '/api/tasks'),
        statusCode: 500,
      ),
    );

    await interceptor.onError(dioError, mockHandler);

    verify(() => mockHandler.next(dioError)).called(1);
  });

  test('clears session on refresh failure', () async {
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/api/tasks'),
      response: Response(
        requestOptions: RequestOptions(path: '/api/tasks'),
        statusCode: 401,
      ),
    );

    when(() => mockStorage.getRefreshToken()).thenAnswer((_) async => null);
    when(() => mockStorage.clearSession()).thenAnswer((_) async => {});

    await interceptor.onError(dioError, mockHandler);

    verify(() => mockStorage.getRefreshToken()).called(1);
    verify(() => mockStorage.clearSession()).called(1);
    verify(() => mockHandler.next(dioError)).called(1);
  });
}
