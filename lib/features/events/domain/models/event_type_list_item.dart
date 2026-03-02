/// Domain model for a single event type in the list response.
class EventTypeListItem {
  final String id;
  final String name;
  final String? description;
  final bool active;
  final String? iconUrl;
  final int? sortOrder;
  final String createdAt;

  const EventTypeListItem({
    required this.id,
    required this.name,
    this.description,
    required this.active,
    this.iconUrl,
    this.sortOrder,
    required this.createdAt,
  });

  factory EventTypeListItem.fromJson(Map<String, dynamic> json) {
    return EventTypeListItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      active: json['active'] as bool? ?? true,
      iconUrl: json['iconUrl'] as String?,
      sortOrder: json['sortOrder'] as int?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  EventTypeListItem copyWith({
    String? id,
    String? name,
    String? description,
    bool? active,
    String? iconUrl,
    int? sortOrder,
    String? createdAt,
  }) {
    return EventTypeListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      active: active ?? this.active,
      iconUrl: iconUrl ?? this.iconUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'active': active,
      'iconUrl': iconUrl,
      'sortOrder': sortOrder,
      // 'createdAt': createdAt, // specific to requirement, usually not needed for update
    };
  }
}
