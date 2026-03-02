class CreateDecorationModel {
  final String id;
  final String name;
  final String eventTypeId;
  final String? eventTypeName;
  final String cityId;
  final String? cityName;
  final String? description;
  final String? inclusions;
  final String? exclusions;
  final double basePrice;
  final List<String> imageUrls;
  final bool active;

  const CreateDecorationModel({
    required this.id,
    required this.name,
    required this.eventTypeId,
    this.eventTypeName,
    required this.cityId,
    this.cityName,
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
      eventTypeName: json['eventTypeName'] as String?,
      cityId: json['cityId'] as String? ?? '',
      cityName: json['cityName'] as String?,
      description: json['description'] as String?,
      inclusions: json['inclusions'] as String?,
      exclusions: json['exclusions'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      imageUrls: urls,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'eventTypeId': eventTypeId,
        'eventTypeName': eventTypeName,
        'cityId': cityId,
        'cityName': cityName,
        'description': description,
        'inclusions': inclusions,
        'exclusions': exclusions,
        'basePrice': basePrice,
        'imageUrls': imageUrls,
        'active': active,
      };
}
