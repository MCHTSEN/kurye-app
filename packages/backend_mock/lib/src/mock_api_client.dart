import 'package:backend_core/backend_core.dart';

class MockApiClient implements ApiClient {
  MockApiClient({Map<String, dynamic>? exampleFeedPayload})
    : _exampleFeedPayload =
          exampleFeedPayload ??
          <String, dynamic>{
            'items': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'alpha',
                'title': 'Mock onboarding checklist',
                'subtitle':
                    'Use this slice as a template for remote list features.',
                'category': 'template',
              },
              <String, dynamic>{
                'id': 'beta',
                'title': 'Runtime services ready',
                'subtitle':
                    'Secure storage, retry, cache, and crash reporting are wired.',
                'category': 'runtime',
              },
              <String, dynamic>{
                'id': 'gamma',
                'title': 'Mock backend active',
                'subtitle':
                    'Default local runs work without external credentials.',
                'category': 'backend',
              },
            ],
            'fetchedAt': '2026-03-08T12:00:00.000Z',
          };

  final Map<String, dynamic> _exampleFeedPayload;

  @override
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    throw UnsupportedError('DELETE $path is not implemented in MockApiClient');
  }

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    switch (path) {
      case '/example-feed':
        return _exampleFeedPayload;
      default:
        throw UnsupportedError('GET $path is not implemented in MockApiClient');
    }
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    throw UnsupportedError('PATCH $path is not implemented in MockApiClient');
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    throw UnsupportedError('POST $path is not implemented in MockApiClient');
  }

  @override
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    throw UnsupportedError('PUT $path is not implemented in MockApiClient');
  }
}
