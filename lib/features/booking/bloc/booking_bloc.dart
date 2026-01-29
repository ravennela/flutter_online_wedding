import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_event.dart';
import 'booking_state.dart';
import '../data/repositories/booking_repository_impl.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepositoryImpl bookingRepository;
  
  BookingBloc(this.bookingRepository) : super(BookingInitial()) {
    on<LoadMyBookings>(_onLoadMyBookings);
    on<CreateBooking>(_onCreateBooking);
    on<ConfirmBooking>(_onConfirmBooking);
  }
  
  Future<void> _onLoadMyBookings(
    LoadMyBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final result = await bookingRepository.getMyBookings();
      result.fold(
        (failure) => emit(BookingError(failure.message)),
        (bookings) => emit(BookingsLoaded(bookings)),
      );
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
  
  Future<void> _onCreateBooking(
    CreateBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final result = await bookingRepository.createBooking(
        event.eventId,
        event.bookingData,
      );
      result.fold(
        (failure) => emit(BookingError(failure.message)),
        (booking) => emit(BookingCreated(booking)),
      );
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
  
  Future<void> _onConfirmBooking(
    ConfirmBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final result = await bookingRepository.confirmBooking(event.bookingId);
      result.fold(
        (failure) => emit(BookingError(failure.message)),
        (booking) => emit(BookingConfirmed(booking)),
      );
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
