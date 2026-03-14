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

  Future<AdminBookingDetailModel> getAdminBookingDetail(String id);
  Future<void> updateBookingStatus(String id, String status);
  Future<void> adminCancelBooking(String id, String reason);
  Future<void> assignVendors(String bookingId, List<String> vendorIds);
  Future<void> deAssignVendor(String bookingId, String vendorId);
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

  @override
  Future<AdminBookingDetailModel> getAdminBookingDetail(String id) async {
    try {
      final response = await apiClient.get(
        ApiConstants.adminBookingDetail.replaceFirst('{id}', id),
      );

      return AdminBookingDetailModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      log("Error fetching admin booking detail: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateBookingStatus(String id, String status) async {
    try {
      await apiClient.patch(
        ApiConstants.updateBookingStatus.replaceFirst('{id}', id),
        data: {'status': status},
      );
    } catch (e) {
      log("Error updating booking status: $e");
      rethrow;
    }
  }

  @override
  Future<void> adminCancelBooking(String id, String reason) async {
    try {
      await apiClient.patch(
        ApiConstants.cancelBooking.replaceFirst('{id}', id),
        data: {'reason': reason},
      );
    } catch (e) {
      log("Error cancelling booking as admin: $e");
      rethrow;
    }
  }
    @override
    Future<void> assignVendors(String bookingId, List<String> vendorIds) async {
      try {
        await apiClient.post(
          ApiConstants.assignVendors.replaceFirst('{id}', bookingId),
          data: {'vendorIds': vendorIds},
        );
      } catch (e) {
        log("Error assigning vendors: $e");
        rethrow;
      }
    }

    @override
    Future<void> deAssignVendor(String bookingId, String vendorId) async {
      try {
        await apiClient.delete(
          ApiConstants.deAssignVendor.replaceFirst('{id}', bookingId).replaceFirst('{vendorId}', vendorId),
        );
      } catch (e) {
        log("Error de-assigning vendor: $e");
        rethrow;
      }
    }
  }

