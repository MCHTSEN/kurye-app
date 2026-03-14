abstract class ApiClient {
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  });

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  });

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  });

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? query,
  });
}
