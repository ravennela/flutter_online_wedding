/// Domain model for a single event type in the list response.
class EventTypeListItem {
  final String id;
  final String name;
  final String? description;
  final bool active;
  final String createdAt;

  const EventTypeListItem({
    required this.id,
    required this.name,
    this.description,
    required this.active,
    required this.createdAt,
  });

  factory EventTypeListItem.fromJson(Map<String, dynamic> json) {
    return EventTypeListItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      active: json['active'] as bool? ?? true,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
