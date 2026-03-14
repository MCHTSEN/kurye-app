import 'package:backend_core/backend_core.dart';

class FakeApiClient implements ApiClient {
  FakeApiClient({
    Map<String, dynamic>? getResponses,
    this.onGet,
  }) : _getResponses = getResponses ?? <String, Map<String, dynamic>>{};

  final Map<String, dynamic> _getResponses;
  final Future<Map<String, dynamic>> Function(String path)? onGet;

  @override
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    throw UnsupportedError('DELETE not configured for $path');
  }

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    if (onGet != null) {
      return onGet!(path);
    }

    final response = _getResponses[path];
    if (response is Map<String, dynamic>) {
      return response;
    }

    throw UnsupportedError('GET not configured for $path');
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    throw UnsupportedError('PATCH not configured for $path');
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    throw UnsupportedError('POST not configured for $path');
  }

  @override
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    throw UnsupportedError('PUT not configured for $path');
  }
}
