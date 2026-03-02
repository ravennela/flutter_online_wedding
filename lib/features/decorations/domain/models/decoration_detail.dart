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
  final num? basePriceRaw; // Raw from API (paise) for edit form

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
    final imageUrlsRaw = json['imageUrls'];
    final List<String> urls = imageUrlsRaw is List
        ? (imageUrlsRaw).map((e) => e.toString()).toList()
        : [];

    return DecorationDetail(
      id: json['id'] as String? ?? '',
      cityId: json['cityId'] as String? ?? '',
      inclusions: json['inclusions'] as String? ?? '',
      exclusions: json['exclusions'] as String? ?? '',
      title: json['name'] as String? ?? '',
      eventTypeId: json['eventTypeId'] as String? ?? '',
      providerName: json['cityName'] as String? ?? 'Premium Decorators',
      providerImage: 'https://via.placeholder.com/150', // Placeholder
      price: '₹${(((json['basePrice'] as num?) ?? 0) / 100).toStringAsFixed(2)}',
      rating: 4.5, // Placeholder
      images: urls.isNotEmpty 
          ? urls 
          : ['https://placehold.co/600x400?text=No+Image'],
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
