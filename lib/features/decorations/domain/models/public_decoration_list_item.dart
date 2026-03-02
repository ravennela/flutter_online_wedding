/// Public decoration list item from GET /api/public/decorations.
/// Handles null thumbnailUrl and price safely.
class PublicDecorationListItem {
  final String id;
  final String name;
  final double price;
  final String? thumbnailUrl;
  final String eventTypeName;
  final String cityName;

  const PublicDecorationListItem({
    required this.id,
    required this.name,
    required this.price,
    this.thumbnailUrl,
    required this.eventTypeName,
    required this.cityName,
  });

  factory PublicDecorationListItem.fromJson(Map<String, dynamic> json) {
    return PublicDecorationListItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      eventTypeName: json['eventTypeName'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
    );
  }

  String get formattedPrice {
    if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(1)}L';
    }
    return '₹${price.toStringAsFixed(0)}';
  }
}
