import 'dart:async';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteSource {
  Future<void> login(String phone);
  Future<UserModel> verifyOtp(String phone, String otp);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteSourceImpl implements AuthRemoteSource {
  final ApiClient apiClient;
  
  AuthRemoteSourceImpl(this.apiClient);
  
  @override
  Future<void> login(String phone) async {
    try {
      await apiClient.post(
        ApiConstants.login,
        data: {'phone': phone},
      );
    } catch (e) {
      throw ServerException('Failed to send OTP: ${e.toString()}');
    }
  }
  
  @override
  Future<UserModel> verifyOtp(String phone, String otp) async {
    try {
      final response = await apiClient.post(
        ApiConstants.verifyOtp,
        data: {
          'phone': phone,
          'otp': otp,
        },
      );
      return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Failed to verify OTP: ${e.toString()}');
    }
  }
  
  @override
  Future<void> logout() async {
    try {
      await apiClient.post(ApiConstants.login.replaceAll('/login', '/logout'));
    } catch (e) {
      throw ServerException('Failed to logout: ${e.toString()}');
    }
  }
  
  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get('/auth/me');
      return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Failed to get current user: ${e.toString()}');
    }
  }
}
