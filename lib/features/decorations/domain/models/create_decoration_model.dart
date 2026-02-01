/// Domain model for create decoration API response.
class CreateDecorationModel {
  final String id;
  final String name;
  final String eventTypeId;
  final String cityId;
  final String? description;
  final String? inclusions;
  final String? exclusions;
  final int basePrice;
  final List<String> imageUrls;
  final bool active;

  const CreateDecorationModel({
    required this.id,
    required this.name,
    required this.eventTypeId,
    required this.cityId,
    this.description,
    this.inclusions,
    this.exclusions,
    required this.basePrice,
    this.imageUrls = const [],
    this.active = true,
  });

  factory CreateDecorationModel.fromJson(Map<String, dynamic> json) {
    final imageUrlsRaw = json['imageUrls'];
    final List<String> urls = imageUrlsRaw is List
        ? (imageUrlsRaw).map((e) => e.toString()).toList()
        : [];

    return CreateDecorationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      eventTypeId: json['eventTypeId'] as String? ?? '',
      cityId: json['cityId'] as String? ?? '',
      description: json['description'] as String?,
      inclusions: json['inclusions'] as String?,
      exclusions: json['exclusions'] as String?,
      basePrice: (json['basePrice'] as num?)?.toInt() ?? 0,
      imageUrls: urls,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'eventTypeId': eventTypeId,
        'cityId': cityId,
        'description': description,
        'inclusions': inclusions,
        'exclusions': exclusions,
        'basePrice': basePrice,
        'imageUrls': imageUrls,
        'active': active,
      };
}
