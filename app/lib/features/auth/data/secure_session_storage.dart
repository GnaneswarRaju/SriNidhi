import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Native sessions use platform secure storage. Browser sessions still rely on
/// the origin's XSS boundary and require HTTPS outside loopback development.
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage(String projectHost)
    : _key = 'srinidhi.$projectHost.session';
  final String _key;
  final _storage = const FlutterSecureStorage();
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> accessToken() => _storage.read(key: _key);
  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: _key);
  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _key, value: persistSessionString);
  @override
  Future<void> removePersistedSession() => _storage.delete(key: _key);
}
