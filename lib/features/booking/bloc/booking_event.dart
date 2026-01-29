import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
  
  @override
  List<Object> get props => [];
}

class LoadMyBookings extends BookingEvent {
  const LoadMyBookings();
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
