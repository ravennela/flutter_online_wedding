/// Domain model for a single event type in the list response.
class EventTypeListItem {
  final String id;
  final String name;
  final String? description;
  final bool active;
  final String? iconUrl;
  final String? iconPublicId;
  final int? sortOrder;
  final String createdAt;

  const EventTypeListItem({
    required this.id,
    required this.name,
    this.description,
    required this.active,
    this.iconUrl,
    this.iconPublicId,
    this.sortOrder,
    required this.createdAt,
  });

  factory EventTypeListItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawName = json['name'];
    final rawIconUrl = json['iconUrl'];
    final iconStr = rawIconUrl is String ? rawIconUrl.trim() : null;
    final rawPublicId = json['iconPublicId'] ?? json['icon_public_id'];
    final publicIdStr = rawPublicId is String ? rawPublicId.trim() : null;
    return EventTypeListItem(
      id: rawId?.toString() ?? '',
      name: rawName?.toString() ?? '',
      description: json['description']?.toString(),
      active: json['active'] == true,
      iconUrl: (iconStr == null || iconStr.isEmpty) ? null : iconStr,
      iconPublicId: (publicIdStr == null || publicIdStr.isEmpty) ? null : publicIdStr,
      sortOrder: json['sortOrder'] is int ? json['sortOrder'] as int : (json['sortOrder'] is num ? (json['sortOrder'] as num).toInt() : null),
      createdAt: json['createdAt']?.toString() ?? json['updatedAt']?.toString() ?? '',
    );
  }

  EventTypeListItem copyWith({
    String? id,
    String? name,
    String? description,
    bool? active,
    String? iconUrl,
    String? iconPublicId,
    int? sortOrder,
    String? createdAt,
  }) {
    return EventTypeListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      active: active ?? this.active,
      iconUrl: iconUrl ?? this.iconUrl,
      iconPublicId: iconPublicId ?? this.iconPublicId,
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
      'iconPublicId': iconPublicId,
      'sortOrder': sortOrder,
    };
  }
}
