import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/event_model.dart';
import '../models/decoration_model.dart';

abstract class EventRemoteSource {
  Future<List<EventModel>> getEvents();
  Future<EventModel> getEventDetail(String eventId);
}

class EventRemoteSourceImpl implements EventRemoteSource {
  final ApiClient apiClient;

  EventRemoteSourceImpl(this.apiClient);

  @override
  Future<List<EventModel>> getEvents() async {
    final response = await apiClient.get(
      '/events',
      requiresAuth: false, // 🔓 public API
    );

    final data = response.data;

    if (data is! List) {
      throw const ServerException('Invalid events response format');
    }

    return data.map((e) => EventModel.fromJson(e)).toList();
  }

  @override
  Future<EventModel> getEventDetail(String eventId) async {
    final response = await apiClient.get(
      '/events/$eventId',
      requiresAuth: false, // 🔓 public API
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw const ServerException('Invalid event detail response format');
    }

    return EventModel.fromJson(data);
  }

  @override
  Future<List<DecorationModel>> getDecorationsByEvent(String eventId) async {
    final response = await apiClient.get(
      '/decorations/event/$eventId',
      requiresAuth: false, // 🔓 public API
    );

    final data = response.data;

    if (data is! List) {
      throw const ServerException('Invalid decorations response format');
    }

    return data.map((e) => DecorationModel.fromJson(e)).toList();
  }
}
