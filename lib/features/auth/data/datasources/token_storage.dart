import 'package:flutter_online/features/auth/domain/models/verify_otp_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Token storage using SharedPreferences.
/// Stores accessToken, refreshToken (if available), userId, and user role.
abstract class TokenStorage {
  Future<void> saveTokens(VerifyOtpModel user);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getUserId();
  Future<String?> getRole();
  Future<VerifyOtpModel?> getStoredUser();
  Future<void> clearTokens();
}

class TokenStorageImpl implements TokenStorage {
  final SharedPreferences _prefs;

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _userIdKey = 'userId';
  static const _roleKey = 'role';
  static const _nameKey = 'name';

  TokenStorageImpl(this._prefs);

  @override
  Future<void> saveTokens(VerifyOtpModel user) async {
    await _prefs.setString(_accessTokenKey, user.token);
    await _prefs.setString(_userIdKey, user.userId);
    await _prefs.setString(_roleKey, user.role);
    await _prefs.setString(_nameKey, user.name);
  }

  @override
  Future<String?> getRole() async {
    return _prefs.getString(_roleKey);
  }

  @override
  Future<VerifyOtpModel?> getStoredUser() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return null;
    return VerifyOtpModel(
      token: token,
      role: await getRole() ?? 'USER',
      userId: await getUserId() ?? '',
      name: await _prefs.getString(_nameKey) ?? '',
    );
  }

  @override
  Future<String?> getAccessToken() async {
    return _prefs.getString(_accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _prefs.getString(_refreshTokenKey);
  }

  @override
  Future<String?> getUserId() async {
    return _prefs.getString(_userIdKey);
  }

  @override
  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_roleKey);
    await _prefs.remove(_nameKey);
  }
}
