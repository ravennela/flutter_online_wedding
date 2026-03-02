import '../../domain/models/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    super.id,
    required super.fullName,
    required super.mobileNumber,
    required super.houseNo,
    required super.area,
    super.landmark,
    required super.city,
    required super.state,
    required super.pincode,
    required super.addressType,
    required super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString(),
      fullName: json['fullName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      houseNo: json['houseNo'] ?? '',
      area: json['area'] ?? '',
      landmark: json['landmark'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      addressType: json['addressType'] ?? 'HOME',
      isDefault: json['default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'houseNo': houseNo,
      'area': area,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'addressType': addressType,
      'default': isDefault,
    };
  }

  factory AddressModel.fromEntity(AddressEntity entity) {
    return AddressModel(
      id: entity.id,
      fullName: entity.fullName,
      mobileNumber: entity.mobileNumber,
      houseNo: entity.houseNo,
      area: entity.area,
      landmark: entity.landmark,
      city: entity.city,
      state: entity.state,
      pincode: entity.pincode,
      addressType: entity.addressType,
      isDefault: entity.isDefault,
    );
  }
}
