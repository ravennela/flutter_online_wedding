import 'package:flutter_online/core/constants/api_constants.dart';
import 'package:flutter_online/core/network/api_client.dart';

import '../models/admin_booking_model.dart';
import 'dart:developer';

abstract class AdminBookingRemoteDataSource {
  Future<AdminBookingResponseModel> getAdminBookings({
    required int page,
    required int size,
    String? status,
    String? city,
    String? paymentStatus,
  });
}

class AdminBookingRemoteDataSourceImpl implements AdminBookingRemoteDataSource {
  final ApiClient apiClient;

  AdminBookingRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AdminBookingResponseModel> getAdminBookings({
    required int page,
    required int size,
    String? status,
    String? city,
    String? paymentStatus,
  }) async {
    try {
      Map<String, String> queryParams = {};

      if (status != null && status != 'All') {
        queryParams['status'] = status.toUpperCase();
      }

      if (city != null && city != 'All Cities') {
        queryParams['city'] = city;
      }

      if (paymentStatus != null && paymentStatus != 'All') {
        queryParams['paymentStatus'] = paymentStatus.toUpperCase();
      }
      final response = await apiClient.get(
        ApiConstants.fetchAdminBookings,
        queryParameters: queryParams,
      );

      return AdminBookingResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      log("Error fetching admin bookings: $e");
      rethrow;
    }
  }
}
