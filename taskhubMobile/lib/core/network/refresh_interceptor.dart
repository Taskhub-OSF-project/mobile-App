import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

class RefreshInterceptor extends Interceptor {
  final Ref ref;
  bool _isRefreshing = false;
  final List<_QueuedRequest> _pendingRequests = [];

  RefreshInterceptor(this.ref);

  SecureStorageService get _storage => ref.read(secureStorageProvider);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 || _isPublicEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      final completer = Completer<Response<dynamic>>();
      _pendingRequests.add(_QueuedRequest(
        requestOptions: err.requestOptions,
        completer: completer,
      ));
      try {
        final response = await completer.future;
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    _isRefreshing = true;

    try {
      final newTokens = await _refreshToken();
      if (newTokens != null) {
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${newTokens['accessToken']}';
        // Need to use a new Dio instance to avoid interceptor loops
        final cloneReq = await Dio().fetch(opts);
        _resolvePendingRequests(cloneReq);
        return handler.resolve(cloneReq);
      } else {
        _resolvePendingRequestsError(err);
        await _storage.clearSession();
        return handler.next(err);
      }
    } catch (e) {
      _resolvePendingRequestsError(err);
      await _storage.clearSession();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Map<String, String>?> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return null;

      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final accessToken = data['token'] as String;
        final newRefreshToken = data['refreshToken'] as String;

        await _storage.saveTokens(
          accessToken: accessToken,
          refreshToken: newRefreshToken,
        );

        return {'accessToken': accessToken, 'refreshToken': newRefreshToken};
      }
    } catch (e) {
      // Refresh failed
    }
    return null;
  }

  void _resolvePendingRequests(Response response) {
    for (final req in _pendingRequests) {
      final opts = req.requestOptions;
      opts.headers['Authorization'] = response.requestOptions.headers['Authorization'];
      Dio().fetch(opts).then((res) {
        req.completer.complete(res);
      }).catchError((e) {
        req.completer.completeError(e);
      });
    }
    _pendingRequests.clear();
  }

  void _resolvePendingRequestsError(DioException err) {
    for (final req in _pendingRequests) {
      req.completer.completeError(err);
    }
    _pendingRequests.clear();
  }

  bool _isPublicEndpoint(String path) {
    final publicPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/auth/verify-email',
      '/auth/refresh',
      '/health',
    ];
    return publicPaths.any((p) => path.endsWith(p));
  }
}

class _QueuedRequest {
  final RequestOptions requestOptions;
  final Completer<Response<dynamic>> completer;

  _QueuedRequest({
    required this.requestOptions,
    required this.completer,
  });
}
