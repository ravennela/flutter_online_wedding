/// Public event item from GET /api/public/events.
/// Used for user-side event types list (separate from admin).

class PublicEventItem {
  final String id;
  final String name;
  final String? imageUrl;

  const PublicEventItem({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory PublicEventItem.fromJson(Map<String, dynamic> json) {
    return PublicEventItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
