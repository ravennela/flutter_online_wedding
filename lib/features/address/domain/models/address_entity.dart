import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String? id;
  final String fullName;
  final String mobileNumber;
  final String houseNo;
  final String area;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final String addressType; // HOME, WORK, OTHER
  final bool isDefault;

  const AddressEntity({
    this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.houseNo,
    required this.area,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    required this.addressType,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        mobileNumber,
        houseNo,
        area,
        landmark,
        city,
        state,
        pincode,
        addressType,
        isDefault,
      ];
}
