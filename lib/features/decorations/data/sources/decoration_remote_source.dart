import 'package:flutter_online/core/constants/api_constants.dart';
import 'package:flutter_online/core/network/api_client.dart';

/// Abstract contract for decoration remote operations.
abstract class DecorationRemoteSource {
  /// Create a decoration package (ADMIN).
  Future<Map<String, dynamic>> createDecoration(Map<String, dynamic> data);

  /// Fetch decorations (ADMIN).
  Future<Map<String, dynamic>> fetchDecorations({
    int page = 0,
    int size = 10,
    String? search,
    String? cityId,
    String? eventTypeId,
    bool? active,
    String? sortBy,
    String? sortDir,
  });

  /// Fetch cities for dropdown (ADMIN).
  /// Response: { content: [{ id, name }], last, page, size, totalElements, totalPages }
  Future<List<Map<String, dynamic>>> fetchCities({
    int page = 0,
    int size = 100,
  });
}

/// Implementation
class DecorationRemoteSourceImpl implements DecorationRemoteSource {
  final ApiClient dioClient;

  DecorationRemoteSourceImpl({required this.dioClient});

  @override
  Future<Map<String, dynamic>> createDecoration(
    Map<String, dynamic> data,
  ) async {
    final response = await dioClient.post(
      ApiConstants.createDecoration,
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> fetchDecorations({
    int page = 0,
    int size = 10,
    String? search,
    String? cityId,
    String? eventTypeId,
    bool? active,
    String? sortBy,
    String? sortDir,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'size': size,
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (cityId != null && cityId.isNotEmpty) {
      queryParams['cityId'] = cityId;
    }
    if (eventTypeId != null && eventTypeId.isNotEmpty) {
      queryParams['eventTypeId'] = eventTypeId;
    }
    if (active != null) {
      queryParams['active'] = active;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }
    if (sortDir != null && sortDir.isNotEmpty) {
      queryParams['sortDir'] = sortDir;
    }

    final response = await dioClient.get(
      ApiConstants.createDecoration,
      queryParameters: queryParams,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCities({
    int page = 0,
    int size = 100,
  }) async {
    final response = await dioClient.get(
      ApiConstants.fetchCities,
      queryParameters: {'page': page, 'size': size},
    );
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
          .toList();
    }
    if (data is Map<String, dynamic>) {
      // API response: { content: [{ id, name }], last, page, size, totalElements, totalPages }
      final content = data['content'] ?? data['data'] ?? data['cities'];
      if (content is List) {
        return content
            .map((e) => e is Map<String, dynamic>
                ? e
                : <String, dynamic>{'id': '', 'name': e.toString()})
            .toList();
      }
    }
    return [];
  }
}
