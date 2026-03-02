import 'package:flutter_online/core/constants/api_constants.dart';
import 'package:flutter_online/core/network/api_client.dart';

abstract class PublicEventsRemoteSource {
  Future<List<Map<String, dynamic>>> getPublicEvents();
}

class PublicEventsRemoteSourceImpl implements PublicEventsRemoteSource {
  final ApiClient apiClient;

  PublicEventsRemoteSourceImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getPublicEvents() async {
    final response = await apiClient.get(
      ApiConstants.publicEvents,
      requiresAuth: false,
    );
    final data = response.data;
    if (data is! List) {
      return [];
    }
    return data
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}
