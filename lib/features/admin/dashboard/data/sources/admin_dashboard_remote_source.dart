import 'dart:developer';
import 'package:flutter_online/core/constants/api_constants.dart';
import 'package:flutter_online/core/network/api_client.dart';
import '../models/admin_dashboard_model.dart';

abstract class AdminDashboardRemoteSource {
  Future<AdminDashboardModel> getAdminDashboardData();
}

class AdminDashboardRemoteSourceImpl implements AdminDashboardRemoteSource {
  final ApiClient apiClient;

  AdminDashboardRemoteSourceImpl({required this.apiClient});

  @override
  Future<AdminDashboardModel> getAdminDashboardData() async {
    try {
      final response = await apiClient.get(ApiConstants.adminDashboard);
      return AdminDashboardModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      log("Error fetching admin dashboard data: $e");
      rethrow;
    }
  }
}
