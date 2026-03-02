import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_detail_event.dart';
import 'booking_detail_state.dart';
import '../../domain/usecases/get_booking_detail_usecase.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';

class BookingDetailBloc extends Bloc<BookingDetailEvent, BookingDetailState> {
  final GetBookingDetailUseCase getBookingDetailUseCase;
  final CancelBookingUseCase cancelBookingUseCase;

  BookingDetailBloc(this.getBookingDetailUseCase, this.cancelBookingUseCase)
      : super(BookingDetailInitial()) {
    on<LoadBookingDetail>(_onLoadBookingDetail);
    on<CancelBooking>(_onCancelBooking);
  }

  Future<void> _onLoadBookingDetail(
    LoadBookingDetail event,
    Emitter<BookingDetailState> emit,
  ) async {
    if (event.bookingId.isEmpty) {
      emit(const BookingDetailError('Invalid booking ID'));
      return;
    }
    emit(BookingDetailLoading());
    final result = await getBookingDetailUseCase(event.bookingId);
    result.fold(
      (failure) => emit(BookingDetailError(failure.message)),
      (booking) => emit(BookingDetailLoaded(booking)),
    );
  }

  Future<void> _onCancelBooking(
    CancelBooking event,
    Emitter<BookingDetailState> emit,
  ) async {
    final current = state;
    if (current is! BookingDetailLoaded || event.bookingId.isEmpty) return;
    emit(BookingDetailCancelInProgress(current.booking));
    final result = await cancelBookingUseCase(event.bookingId);
    result.fold(
      (failure) => emit(BookingDetailCancelFailed(failure.message, event.bookingId)),
      (_) => emit(BookingDetailCancelSuccess(event.bookingId)),
    );
  }
}
