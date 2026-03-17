import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  static Future<void> saveUser(String userJson) async {
    await _storage.write(key: AppConstants.userKey, value: userJson);
  }

  static Future<String?> getUser() async {
    return await _storage.read(key: AppConstants.userKey);
  }

  static Future<void> deleteUser() async {
    await _storage.delete(key: AppConstants.userKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<bool> hasToken() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }
}
