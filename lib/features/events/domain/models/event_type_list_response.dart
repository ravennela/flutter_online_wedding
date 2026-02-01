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
    final contentList = json['content'] as List<dynamic>? ?? [];
    return EventTypeListResponse(
      content: contentList
          .map((e) => EventTypeListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      last: json['last'] as bool? ?? true,
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 10,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}
