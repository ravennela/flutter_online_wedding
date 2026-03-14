class VendorEntity {
  final String id;
  final String? name;
  final String phone;
  final String companyName;
  final String? city;
  final String? address;
  final String? description;
  final String serviceType;
  final double rating;
  final bool active;
  final bool? assigned;

  VendorEntity({
    required this.id,
    this.name,
    required this.phone,
    required this.companyName,
    this.city,
    this.address,
    this.description,
    required this.serviceType,
    required this.rating,
    required this.active,
    this.assigned,
  });
}
