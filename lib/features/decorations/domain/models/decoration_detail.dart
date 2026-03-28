class DecorationDetail {
  final String id;
  final String title;
  final String cityId;
  final String providerName;
  final String providerImage;
  final String price;
  final String eventTypeId;
  final String startingPriceLabel;
  final double rating;
  final String inclusions;
  final String exclusions;
  final List<String> images;
  final List<String> tags;
  final Map<String, String> features; // Title: Description
  final String description;
  final bool active; // Added active field
  final num? basePriceRaw; // Raw from API (Rupees) for edit form

  const DecorationDetail({
    required this.id,
    required this.title,
    required this.cityId,
    required this.eventTypeId,
    required this.providerName,
    required this.providerImage,
    required this.inclusions,
    required this.exclusions,
    required this.price,
    this.startingPriceLabel = "Starting from",
    required this.rating,
    required this.images,
    required this.tags,
    required this.features,
    this.description = '',
    this.active = true,
    this.basePriceRaw,
  });

  List<String> get imageUrls => images; // Getter for compatibility

  factory DecorationDetail.fromJson(Map<String, dynamic> json) {
    List<String> urls = [];
    final imageUrlsRaw = json['imageUrls'];
    if (imageUrlsRaw is List) {
      urls = imageUrlsRaw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    if (urls.isEmpty) {
      final imgs = json['images'];
      if (imgs is List) {
        urls = imgs
            .map((e) {
              if (e is Map) {
                return (e['imageUrl'] ?? e['url'] ?? e['image_url'])?.toString() ?? '';
              }
              return e.toString();
            })
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }

    return DecorationDetail(
      id: json['id'] as String? ?? '',
      cityId: json['cityId'] as String? ?? '',
      inclusions: json['inclusions'] as String? ?? '',
      exclusions: json['exclusions'] as String? ?? '',
      title: json['name'] as String? ?? '',
      eventTypeId: json['eventTypeId'] as String? ?? '',
      providerName: json['cityName'] as String? ?? 'Premium Decorators',
      providerImage: urls.isNotEmpty ? urls.first : 'https://via.placeholder.com/150',
      price: '₹${((json['basePrice'] as num?) ?? 0).toStringAsFixed(2)}',
      rating: 4.5, // Placeholder
      images: urls,
      tags: [
        if (json['eventTypeName'] != null) json['eventTypeName'] as String,
        if (json['cityName'] != null) json['cityName'] as String,
        'Wedding', // Default tag
      ],
      features: {
        if (json['inclusions'] != null && (json['inclusions'] as String).isNotEmpty) 
          'Inclusions': json['inclusions'] as String,
        if (json['exclusions'] != null && (json['exclusions'] as String).isNotEmpty) 
          'Exclusions': json['exclusions'] as String,
      },
      description: json['description'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      basePriceRaw: json['basePrice'] as num?,
    );
  }
}
