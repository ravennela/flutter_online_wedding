import '../../domain/entities/vendor_entity.dart';

class VendorModel extends VendorEntity {
  VendorModel({
    required super.id,
    super.name,
    required super.phone,
    required super.companyName,
    super.city,
    super.address,
    super.description,
    required super.serviceType,
    required super.rating,
    required super.active,
    super.assigned,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: (json['vendorId'] ?? json['id'] ?? '').toString(),
      name: json['vendorName'] ?? json['name'],
      phone: json['phone'] ?? '',
      companyName: json['companyName'] ?? '',
      city: json['city'],
      address: json['address'],
      description: json['description'],
      serviceType: json['serviceType'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      active: json['active'] ?? false,
      assigned: json['assigned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'companyName': companyName,
      'city': city,
      'address': address,
      'description': description,
      'serviceType': serviceType,
      'rating': rating,
      'active': active,
      'assigned': assigned,
    };
  }
}
