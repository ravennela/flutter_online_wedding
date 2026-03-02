import 'package:flutter_online/core/constants/api_constants.dart';
import 'package:flutter_online/core/network/api_client.dart';

abstract class PublicDecorationRemoteSource {
  Future<Map<String, dynamic>> getDecorations({
    required String cityId,
    String? eventTypeId,
    int page = 0,
    int size = 10,
  });

  Future<Map<String, dynamic>> getDecorationDetail(String id);
}

class PublicDecorationRemoteSourceImpl implements PublicDecorationRemoteSource {
  final ApiClient apiClient;

  PublicDecorationRemoteSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getDecorations({
    required String cityId,
    String? eventTypeId,
    int page = 0,
    int size = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'cityId': cityId,
      'page': page,
      'size': size,
    };
    if (eventTypeId != null && eventTypeId.isNotEmpty) {
      queryParams['eventTypeId'] = eventTypeId;
    }

    final response = await apiClient.get(
      ApiConstants.publicDecorations,
      queryParameters: queryParams,
      requiresAuth: false,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getDecorationDetail(String id) async {
    final url = ApiConstants.publicDecorationDetail.replaceAll('{id}', id);
    final response = await apiClient.get(url, requiresAuth: false);
    return response.data as Map<String, dynamic>;
  }
}
