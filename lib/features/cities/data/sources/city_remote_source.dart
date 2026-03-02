import 'package:flutter_online/core/constants/api_constants.dart';
import 'package:flutter_online/core/network/api_client.dart';

abstract class CityRemoteSource {
  Future<List<Map<String, dynamic>>> getCities();
}

class CityRemoteSourceImpl implements CityRemoteSource {
  final ApiClient apiClient;

  CityRemoteSourceImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getCities() async {
    final response = await apiClient.get(
      ApiConstants.fetchCities,
      requiresAuth: false,
    );
    final data = response.data;
    List<dynamic> content;
    if (data is List) {
      content = data;
    } else if (data is Map<String, dynamic> && data['content'] != null) {
      content = data['content'] as List<dynamic>;
    } else {
      return [];
    }
    return content
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}
