import 'dart:developer';
import 'package:flutter_online/core/constants/api_constants.dart';
import 'package:flutter_online/core/network/api_client.dart';
import '../models/vendor_model.dart';

abstract class VendorRemoteDataSource {
  Future<List<VendorModel>> getVendors({String? bookingId});
}

class VendorRemoteDataSourceImpl implements VendorRemoteDataSource {
  final ApiClient apiClient;

  VendorRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<VendorModel>> getVendors({String? bookingId}) async {
    try {
      final String url = bookingId != null 
          ? "${ApiConstants.vendorAssignments}?bookingId=$bookingId"
          : ApiConstants.adminVendors;

      final response = await apiClient.get(url);
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => VendorModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception("Invalid response format: expected a list of vendors");
      }
    } catch (e) {
      log("Error fetching vendors: $e");
      rethrow;
    }
  }
}
