import 'package:backend_core/backend_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_dio/sentry_dio.dart';

class DioApiClient implements ApiClient {
  DioApiClient({
    required String baseUrl,
    required Future<bool> Function() tryRefreshToken,
    required VoidCallback onUnauthorized,
    required VoidCallback? onInsufficientCredit,
  }) : _tryRefreshToken = tryRefreshToken,
       _onUnauthorized = onUnauthorized,
       _onInsufficientCredit = onInsufficientCredit {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _log.d('${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _log.d(
            '${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          _log.w(
            'Error $statusCode ${error.requestOptions.path}: ${error.message}',
          );

          if (_isUnauthorized(statusCode) && !_alreadyRetried(error)) {
            _log.i('Attempting token refresh...');
            final refreshed = await _tryRefreshToken();

            if (refreshed) {
              _log.i('Token refresh success, retrying request');
              final requestOptions = error.requestOptions;
              requestOptions.extra['retriedAfterRefresh'] = true;

              try {
                final response = await _dio.fetch<dynamic>(requestOptions);
                handler.resolve(response);
                return;
              } on DioException catch (_) {
                _log.w('Retry after token refresh failed');
              }
            }

            _log.w('Unauthorized, triggering login requirement');
            _onUnauthorized();
          }

          if (_isCreditIssue(error.response)) {
            _log.w('Insufficient credit detected');
            _onInsufficientCredit?.call();
          }

          handler.next(error);
        },
      ),
    );

    _dio.addSentry();
  }

  late final Dio _dio;
  final Future<bool> Function() _tryRefreshToken;
  final VoidCallback _onUnauthorized;
  final VoidCallback? _onInsufficientCredit;

  static final _log = AppLogger('DioApiClient', tag: LogTag.network);

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: query,
    );

    return response.data ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: data,
    );

    return response.data ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      path,
      data: data,
    );

    return response.data ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      path,
      data: data,
    );

    return response.data ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      path,
      queryParameters: query,
    );

    return response.data ?? <String, dynamic>{};
  }

  bool _alreadyRetried(DioException error) {
    return error.requestOptions.extra['retriedAfterRefresh'] == true;
  }

  bool _isUnauthorized(int? statusCode) {
    return statusCode == 401;
  }

  bool _isCreditIssue(Response<dynamic>? response) {
    final statusCode = response?.statusCode;
    if (statusCode == 402) {
      return true;
    }

    if (statusCode != 403) {
      return false;
    }

    final data = response?.data;

    if (data is Map<String, dynamic>) {
      final code = data['code'] ?? data['errorCode'];
      return code == 'insufficient_credit';
    }

    if (data is Map) {
      final code = data['code'] ?? data['errorCode'];
      return code == 'insufficient_credit';
    }

    return false;
  }
}
