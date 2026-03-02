import 'package:flutter_online/core/constants/api_constants.dart';
import 'package:flutter_online/core/network/api_client.dart';

abstract class AdminHomeRemoteSource {
  Future<Map<String, dynamic>> getAdminHome();
}

class AdminHomeRemoteSourceImpl implements AdminHomeRemoteSource {
  final ApiClient apiClient;

  AdminHomeRemoteSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getAdminHome() async {
    final response = await apiClient.get(
      ApiConstants.adminHome,
      requiresAuth: true,
    );
    return response.data as Map<String, dynamic>;
  }
}
