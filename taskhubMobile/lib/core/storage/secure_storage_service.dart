import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  // Convenience helpers for auth tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      write(StorageKeys.accessToken, accessToken),
      write(StorageKeys.refreshToken, refreshToken),
      write(StorageKeys.isLoggedIn, 'true'),
    ]);
  }

  Future<void> saveUserSession({
    required int userId,
    required String role,
    required String email,
    required String fullName,
  }) async {
    await Future.wait([
      write(StorageKeys.userId, userId.toString()),
      write(StorageKeys.userRole, role),
      write(StorageKeys.userEmail, email),
      write(StorageKeys.userFullName, fullName),
    ]);
  }

  Future<String?> getAccessToken() => read(StorageKeys.accessToken);
  Future<String?> getRefreshToken() => read(StorageKeys.refreshToken);
  Future<int?> getUserId() async {
    final val = await read(StorageKeys.userId);
    return val != null ? int.tryParse(val) : null;
  }

  Future<void> clearSession() async {
    await Future.wait([
      delete(StorageKeys.accessToken),
      delete(StorageKeys.refreshToken),
      delete(StorageKeys.userId),
      delete(StorageKeys.userRole),
      delete(StorageKeys.userEmail),
      delete(StorageKeys.userFullName),
      write(StorageKeys.isLoggedIn, 'false'),
    ]);
  }

  Future<bool> isLoggedIn() async {
    final val = await read(StorageKeys.isLoggedIn);
    return val == 'true';
  }
}
