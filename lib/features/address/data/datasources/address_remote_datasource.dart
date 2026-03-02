import 'package:flutter_online/core/constants/api_constants.dart';
import 'package:flutter_online/core/network/api_client.dart';
import '../models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<AddressModel> createAddress(AddressModel address, String userId);
  Future<List<AddressModel>> getMyAddresses(String userId);
  Future<void> deleteAddress(String addressId);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiClient apiClient;

  AddressRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AddressModel> createAddress(
    AddressModel address,
    String userId,
  ) async {
    final response = await apiClient.post(
      ApiConstants.createAddressApi,
      queryParameters: {'userId': userId},
      data: address.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AddressModel.fromJson(response.data);
    } else {
      throw Exception('Failed to create address');
    }
  }

  @override
  Future<List<AddressModel>> getMyAddresses(String userId) async {
    final response = await apiClient.get(
      ApiConstants.getAddressesApi,
      queryParameters: {'userId': userId},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => AddressModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch addresses');
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await apiClient.delete(
      ApiConstants.deleteAddressApi.replaceFirst('{id}', addressId),
    );
  }
}
