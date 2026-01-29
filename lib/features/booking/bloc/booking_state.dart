import 'package:equatable/equatable.dart';
import '../data/models/booking_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();
  
  @override
  List<Object> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingsLoaded extends BookingState {
  final List<BookingModel> bookings;
  
  const BookingsLoaded(this.bookings);
  
  @override
  List<Object> get props => [bookings];
}

class BookingCreated extends BookingState {
  final BookingModel booking;
  
  const BookingCreated(this.booking);
  
  @override
  List<Object> get props => [booking];
}

class BookingConfirmed extends BookingState {
  final BookingModel booking;
  
  const BookingConfirmed(this.booking);
  
  @override
  List<Object> get props => [booking];
}

class BookingError extends BookingState {
  final String message;
  
  const BookingError(this.message);
  
  @override
  List<Object> get props => [message];
}
