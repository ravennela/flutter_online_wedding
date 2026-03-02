import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

/// Load first page (or refresh) of my bookings.
class LoadMyBookings extends BookingEvent {
  final int page;

  const LoadMyBookings({this.page = 0});

  @override
  List<Object?> get props => [page];
}

/// Load next page (pagination).
class LoadMoreMyBookings extends BookingEvent {
  const LoadMoreMyBookings();
}

class CreateBooking extends BookingEvent {
  final String eventId;
  final Map<String, dynamic> bookingData;

  const CreateBooking(this.eventId, this.bookingData);

  @override
  List<Object> get props => [eventId, bookingData];
}

class ConfirmBooking extends BookingEvent {
  final String bookingId;

  const ConfirmBooking(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}
