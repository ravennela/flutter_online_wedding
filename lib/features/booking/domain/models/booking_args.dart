import 'package:flutter/material.dart';
import 'package:flutter_online/features/address/domain/models/address_entity.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_detail.dart';

class BookingArgs {
  final PublicDecorationDetail decorationDetail;
  final AddressEntity address;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  BookingArgs({
    required this.decorationDetail,
    required this.address,
    this.selectedDate,
    this.selectedTime,
  });

  BookingArgs copyWith({
    PublicDecorationDetail? decorationDetail,
    AddressEntity? address,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
  }) {
    return BookingArgs(
      decorationDetail: decorationDetail ?? this.decorationDetail,
      address: address ?? this.address,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }
}
