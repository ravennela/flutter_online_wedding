import 'package:flutter_online/features/address/domain/models/address_entity.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_detail.dart';

class BookingArgs {
  final PublicDecorationDetail decorationDetail;
  final AddressEntity address;
  final DateTime? selectedDate;

  BookingArgs({
    required this.decorationDetail,
    required this.address,
    this.selectedDate,
  });

  BookingArgs copyWith({
    PublicDecorationDetail? decorationDetail,
    AddressEntity? address,
    DateTime? selectedDate,
  }) {
    return BookingArgs(
      decorationDetail: decorationDetail ?? this.decorationDetail,
      address: address ?? this.address,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
