
// features/auth/data/datasources/auth_local_data_source.dart
import 'dart:convert';
import 'package:flutter_online/features/auth/domain/models/verify_otp_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/user_model.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  AuthLocalDataSource(this._storage);

  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_data';

  // Save JWT
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Get JWT
  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  // Save user
  Future<void> saveUser(VerifyOtpModel user) async {
    await _storage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  // Get user
  Future<VerifyOtpModel?> getUser() async {
    final data = await _storage.read(key: _userKey);
    if (data == null) return null;
    return VerifyOtpModel.fromJson(jsonDecode(data));
  }

  // Clear everything (logout)
  Future<void> clearAll() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
