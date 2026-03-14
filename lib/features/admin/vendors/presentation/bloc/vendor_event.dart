import 'package:equatable/equatable.dart';

abstract class VendorEvent extends Equatable {
  const VendorEvent();

  @override
  List<Object?> get props => [];
}

class GetVendorsEvent extends VendorEvent {
  final String? bookingId;
  const GetVendorsEvent({this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}
