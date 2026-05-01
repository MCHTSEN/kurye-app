import 'package:kuryem/core/runtime/secure_storage_service.dart';

class FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = <String, String>{};

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }
}
