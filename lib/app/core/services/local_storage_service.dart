import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  final FlutterSecureStorage _storage;
  final Map<String, String> _cache = {};
  bool _isInitialized = false;

  LocalStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final all = await _storage.readAll();
      _cache.addAll(all);
    } catch (_) {
      // Fallback para cache vazio em caso de erro ou ambiente de teste
    }
    _isInitialized = true;
  }

  bool getBool(String key, {bool defaultValue = false}) {
    final value = _cache[key];
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  Future<void> setBool(String key, bool value) async {
    _cache[key] = value.toString();
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (_) {}
  }

  String? getString(String key) {
    return _cache[key];
  }

  Future<void> setString(String key, String value) async {
    _cache[key] = value;
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {}
  }

  Future<void> remove(String key) async {
    _cache.remove(key);
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  Future<void> clear() async {
    _cache.clear();
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
