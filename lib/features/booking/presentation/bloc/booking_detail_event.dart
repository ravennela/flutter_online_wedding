import 'package:equatable/equatable.dart';

abstract class BookingDetailEvent extends Equatable {
  const BookingDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookingDetail extends BookingDetailEvent {
  final String bookingId;

  const LoadBookingDetail(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class CancelBooking extends BookingDetailEvent {
  final String bookingId;

  const CancelBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}
