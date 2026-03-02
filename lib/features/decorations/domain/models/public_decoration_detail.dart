/// Public decoration detail from GET /api/public/decorations/{id}.
/// Handles null image URLs and optional fields safely.
class PublicDecorationDetail {
  final String id;
  final String name;
  final double price;
  final String? thumbnailUrl;
  final String eventTypeName;
  final String cityName;
  final String? description;
  final List<String> imageUrls;
  final String? providerName;
  final String? inclusions;
  final String? exclusions;
  final String? eventTypeId;
  final String? cityId;

  const PublicDecorationDetail({
    required this.id,
    required this.name,
    required this.price,
    this.thumbnailUrl,
    required this.eventTypeName,
    required this.cityName,
    this.description,
    this.imageUrls = const [],
    this.providerName,
    this.inclusions,
    this.exclusions,
    this.eventTypeId,
    this.cityId,
  });

  factory PublicDecorationDetail.fromJson(Map<String, dynamic> json) {
    final imageUrlsRaw = json['imageUrls'];
    final List<String> urls = imageUrlsRaw is List
        ? (imageUrlsRaw).map((e) => e.toString()).toList()
        : [];

    return PublicDecorationDetail(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      eventTypeName: json['eventTypeName'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
      description: json['description'] as String?,
      imageUrls: urls,
      providerName: json['providerName'] as String?,
      inclusions: json['inclusions'] as String?,
      exclusions: json['exclusions'] as String?,
      eventTypeId: json['eventTypeId'] as String?,
      cityId: json['cityId'] as String?,
    );
  }

  String get formattedPrice {
    if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(1)}L';
    }
    return '₹${price.toStringAsFixed(0)}';
  }

  String get firstImageUrl =>
      imageUrls.isNotEmpty ? imageUrls.first : (thumbnailUrl ?? '');
}
