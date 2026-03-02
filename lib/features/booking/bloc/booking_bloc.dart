import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_event.dart';
import 'booking_state.dart';
import '../data/repositories/booking_repository_impl.dart';
import '../domain/usecases/get_my_bookings_usecase.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepositoryImpl bookingRepository;
  final GetMyBookingsUseCase getMyBookingsUseCase;

  static const int pageSize = 10;

  BookingBloc({
    required this.bookingRepository,
    required this.getMyBookingsUseCase,
  }) : super(BookingInitial()) {
    on<LoadMyBookings>(_onLoadMyBookings);
    on<LoadMoreMyBookings>(_onLoadMoreMyBookings);
    on<CreateBooking>(_onCreateBooking);
    on<ConfirmBooking>(_onConfirmBooking);
  }

  Future<void> _onLoadMyBookings(
    LoadMyBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    final result = await getMyBookingsUseCase(event.page, pageSize);
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (pageResult) => emit(BookingsLoaded(
        bookings: pageResult.content,
        hasMore: pageResult.hasMore,
        currentPage: pageResult.number,
      )),
    );
  }

  Future<void> _onLoadMoreMyBookings(
    LoadMoreMyBookings event,
    Emitter<BookingState> emit,
  ) async {
    final current = state;
    if (current is! BookingsLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    final nextPage = current.currentPage + 1;
    final result = await getMyBookingsUseCase(nextPage, pageSize);
    result.fold(
      (failure) => emit(current.copyWith(isLoadingMore: false)),
      (pageResult) {
        final merged = [...current.bookings, ...pageResult.content];
        emit(BookingsLoaded(
          bookings: merged,
          hasMore: pageResult.hasMore,
          currentPage: pageResult.number,
          isLoadingMore: false,
        ));
      },
    );
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
