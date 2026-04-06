/// Single “included meeveduka” tile (e.g. Floral Design, Ambient Lighting).
class IncludedMeeveduka {
  final String title;
  final String description;
  /// Semantic key for UI icons: e.g. `flower`, `lightbulb`, `handyman`, `architecture`.
  final String iconName;

  const IncludedMeeveduka({
    required this.title,
    required this.description,
    this.iconName = 'flower',
  });

  factory IncludedMeeveduka.fromJson(Map<String, dynamic> json) {
    return IncludedMeeveduka(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? json['subtitle'] as String? ?? '',
      iconName: json['iconName'] as String? ?? json['icon'] as String? ?? 'flower',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'iconName': iconName,
      };
}

/// Creative lead shown on editorial detail layouts.
class CreativeDirectorInfo {
  final String name;
  final String role;
  final String quote;
  final double rating;
  final String imageUrl;

  const CreativeDirectorInfo({
    required this.name,
    required this.role,
    required this.quote,
    this.rating = 4.9,
    required this.imageUrl,
  });

  factory CreativeDirectorInfo.fromJson(Map<String, dynamic> json) {
    return CreativeDirectorInfo(
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      quote: json['quote'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'quote': quote,
        'rating': rating,
        'imageUrl': imageUrl,
      };
}

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
  final bool active;
  final num? basePriceRaw;

  /// Small-caps eyebrow above the hero title (e.g. “Floral Mastery”).
  final String? categoryLabel;

  /// Section heading for the narrative block (e.g. “01 The Vision”).
  final String visionSectionTitle;

  /// Grid items for “Included meevedukas” / services.
  final List<IncludedMeeveduka> includedMeevedukas;

  /// Optional numeric range for “Investment” cards; falls back to [price] / [basePriceRaw].
  final num? investmentMin;
  final num? investmentMax;

  /// Subcopy under the investment range (guest count, venue scale, etc.).
  final String? investmentNote;

  /// Booking sidebar: creative lead.
  final CreativeDirectorInfo? creativeDirector;

  /// Optional testimonial for editorial footers / sidebars.
  final String? testimonialQuote;
  final String? testimonialAttribution;

  /// Extra count shown on gallery thumb overlays (e.g. +12).
  final int? galleryExtraCount;

  /// Card subtitle for collection grids (e.g. “Full Venue Installation”).
  final String category;

  /// User-saved / wishlist state for collection cards.
  final bool isFavorited;

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
    this.categoryLabel,
    this.visionSectionTitle = '01 The Vision',
    this.includedMeevedukas = const [],
    this.investmentMin,
    this.investmentMax,
    this.investmentNote,
    this.creativeDirector,
    this.testimonialQuote,
    this.testimonialAttribution,
    this.galleryExtraCount,
    this.category = '',
    this.isFavorited = false,
  });

  List<String> get imageUrls => images;

  /// Primary image for listings (first gallery image).
  String get imageUrl => images.isNotEmpty ? images.first : providerImage;

  /// Alias for grids: prefers [investmentMin]/[investmentMax], else [price].
  String get cardPriceRangeDisplay => investmentRangeDisplay;

  /// Investment line for cards; prefers min/max when both are set.
  String get investmentRangeDisplay {
    if (investmentMin != null && investmentMax != null) {
      final a = investmentMin!.round();
      final b = investmentMax!.round();
      return '₹$a — ₹$b';
    }
    if (basePriceRaw != null) {
      return '₹${basePriceRaw!.round()}';
    }
    return price;
  }

  /// Meeveduka tiles: explicit list, else first entries from [features].
  List<IncludedMeeveduka> get resolvedIncludedMeevedukas {
    if (includedMeevedukas.isNotEmpty) return includedMeevedukas;
    final out = <IncludedMeeveduka>[];
    final icons = ['flower', 'lightbulb', 'handyman', 'architecture'];
    var i = 0;
    for (final e in features.entries) {
      if (i >= 4) break;
      out.add(IncludedMeeveduka(
        title: e.key,
        description: e.value,
        iconName: icons[i % icons.length],
      ));
      i++;
    }
    return out;
  }

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

    List<IncludedMeeveduka> meevedukas = [];
    final meevedukasRaw = json['includedMeevedukas'] ?? json['included_meevedukas'];
    if (meevedukasRaw is List) {
      for (final e in meevedukasRaw) {
        if (e is Map<String, dynamic>) {
          meevedukas.add(IncludedMeeveduka.fromJson(e));
        }
      }
    }

    CreativeDirectorInfo? director;
    final dirRaw = json['creativeDirector'] ?? json['creative_director'];
    if (dirRaw is Map<String, dynamic>) {
      director = CreativeDirectorInfo.fromJson(dirRaw);
    }

    final basePrice = json['basePrice'] as num?;

    return DecorationDetail(
      id: json['id'] as String? ?? '',
      cityId: json['cityId'] as String? ?? '',
      inclusions: json['inclusions'] as String? ?? '',
      exclusions: json['exclusions'] as String? ?? '',
      title: json['name'] as String? ?? '',
      eventTypeId: json['eventTypeId'] as String? ?? '',
      providerName: json['cityName'] as String? ?? 'Premium Decorators',
      providerImage: urls.isNotEmpty ? urls.first : 'https://via.placeholder.com/150',
      price: '₹${((basePrice) ?? 0).toStringAsFixed(2)}',
      rating: 4.5,
      images: urls,
      tags: [
        if (json['eventTypeName'] != null) json['eventTypeName'] as String,
        if (json['cityName'] != null) json['cityName'] as String,
        'Wedding',
      ],
      features: {
        if (json['inclusions'] != null && (json['inclusions'] as String).isNotEmpty)
          'Inclusions': json['inclusions'] as String,
        if (json['exclusions'] != null && (json['exclusions'] as String).isNotEmpty)
          'Exclusions': json['exclusions'] as String,
      },
      description: json['description'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      basePriceRaw: basePrice,
      categoryLabel: json['categoryLabel'] as String? ?? json['category_label'] as String?,
      visionSectionTitle:
          json['visionSectionTitle'] as String? ?? json['vision_section_title'] as String? ?? '01 The Vision',
      includedMeevedukas: meevedukas,
      investmentMin: json['investmentMin'] as num? ?? json['investment_min'] as num?,
      investmentMax: json['investmentMax'] as num? ?? json['investment_max'] as num?,
      investmentNote: json['investmentNote'] as String? ?? json['investment_note'] as String?,
      creativeDirector: director,
      testimonialQuote: json['testimonialQuote'] as String? ?? json['testimonial_quote'] as String?,
      testimonialAttribution:
          json['testimonialAttribution'] as String? ?? json['testimonial_attribution'] as String?,
      galleryExtraCount: json['galleryExtraCount'] as int? ?? json['gallery_extra_count'] as int?,
      category: json['category'] as String? ??
          json['packageCategory'] as String? ??
          json['eventTypeName'] as String? ??
          '',
      isFavorited: json['isFavorited'] as bool? ?? json['is_favorited'] as bool? ?? json['favorite'] as bool? ?? false,
    );
  }
}
