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
  });

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
    );
  }
}
