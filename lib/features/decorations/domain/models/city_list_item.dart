/// Domain model for a city in dropdown/list.
class CityListItem {
  final String id;
  final String name;

  const CityListItem({
    required this.id,
    required this.name,
  });

  factory CityListItem.fromJson(Map<String, dynamic> json) {
    return CityListItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
