/// City item from GET /api/admin/cities.
class CityItem {
  final String id;
  final String name;

  const CityItem({
    required this.id,
    required this.name,
  });

  factory CityItem.fromJson(Map<String, dynamic> json) {
    return CityItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
