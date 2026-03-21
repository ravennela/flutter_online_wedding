class DecorationListItem {
  final String id;
  final String name;
  final String description;
  final String? inclusions;
  final String? exclusions;
  final double basePrice;
  final bool active;
  final String cityId;
  final String cityName;
  final String eventTypeId;
  final String eventTypeName;
  /// From API `imageUrls` or `images[].imageUrl`.
  final List<String> imageUrls;

  const DecorationListItem({
    required this.id,
    required this.name,
    required this.description,
    this.inclusions,
    this.exclusions,
    required this.basePrice,
    required this.active,
    required this.cityId,
    required this.cityName,
    required this.eventTypeId,
    required this.eventTypeName,
    this.imageUrls = const [],
  });

  String? get thumbnailUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  static List<String> _parseImageUrls(Map<String, dynamic> json) {
    final raw = json['imageUrls'];
    if (raw is List) {
      final u = raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      if (u.isNotEmpty) return u;
    }
    final imgs = json['images'];
    if (imgs is List) {
      return imgs
          .map((e) {
            if (e is Map) {
              return (e['imageUrl'] ?? e['url'] ?? e['image_url'])?.toString() ?? '';
            }
            return e.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  factory DecorationListItem.fromJson(Map<String, dynamic> json) {
    return DecorationListItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      inclusions: json['inclusions'] as String?,
      exclusions: json['exclusions'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      active: json['active'] as bool? ?? false,
      cityId: json['cityId'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
      eventTypeId: json['eventTypeId'] as String? ?? '',
      eventTypeName: json['eventTypeName'] as String? ?? '',
      imageUrls: _parseImageUrls(json),
    );
  }
}
