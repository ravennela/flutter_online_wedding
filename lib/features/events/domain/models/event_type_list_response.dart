import 'package:flutter_online/features/events/domain/models/event_type_list_item.dart';

/// Paginated response for event types list.
class EventTypeListResponse {
  final List<EventTypeListItem> content;
  final bool last;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  const EventTypeListResponse({
    required this.content,
    required this.last,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory EventTypeListResponse.fromJson(Map<String, dynamic> json) {
    final contentRaw = json['content'];
    final contentList = contentRaw is List ? contentRaw : <dynamic>[];
    return EventTypeListResponse(
      content: contentList
          .map((e) => EventTypeListItem.fromJson(e is Map<String, dynamic> ? e : <String, dynamic>{}))
          .toList(),
      last: json['last'] == true,
      page: json['page'] is int ? json['page'] as int : (json['page'] is num ? (json['page'] as num).toInt() : 0),
      size: json['size'] is int ? json['size'] as int : (json['size'] is num ? (json['size'] as num).toInt() : 10),
      totalElements: json['totalElements'] is int ? json['totalElements'] as int : (json['totalElements'] is num ? (json['totalElements'] as num).toInt() : 0),
      totalPages: json['totalPages'] is int ? json['totalPages'] as int : (json['totalPages'] is num ? (json['totalPages'] as num).toInt() : 0),
    );
  }
}
