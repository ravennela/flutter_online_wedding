import 'package:flutter_online/core/constants/api_constants.dart';
import 'package:flutter_online/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Abstract contract
abstract class EventTypeRemoteDatasource {
  Future<Map<String, dynamic>> createEventType(
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>> fetchEventTypes({
    required int page,
    required int size,
    String? search,
    bool? active,
  });
}

/// Implementation
class EventTypeRemoteDatasourceImpl
    implements EventTypeRemoteDatasource {
  final ApiClient dioClient;
  EventTypeRemoteDatasourceImpl({required this.dioClient});

  /// ➕ Create Event Type (ADMIN)
  @override
  Future<Map<String, dynamic>> createEventType(
    Map<String, dynamic> data,
  ) async {
    try {
      final String url = ApiConstants.createEventType;

      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final String token =
          preferences.getString(ApiConstants.token) ?? "";

      final headers = {
        "Authorization": "Bearer $token",
      };

      final response = await dioClient.post(
        url,
        data: data,
        //options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 📄 Get Event Types (Admin list with search & pagination)
  @override
  Future<Map<String, dynamic>> fetchEventTypes({
    required int page,
    required int size,
    String? search,
    bool? active,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (active != null) {
      queryParams['active'] = active;
    }

    final response = await dioClient.get(
      ApiConstants.fetchEventTypes,
      queryParameters: queryParams,
    );

    return response.data as Map<String, dynamic>;
  }
}
