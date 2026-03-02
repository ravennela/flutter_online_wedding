import 'package:equatable/equatable.dart';
import '../../data/models/booking_detail_model.dart';

abstract class BookingDetailState extends Equatable {
  const BookingDetailState();

  @override
  List<Object?> get props => [];
}

class BookingDetailInitial extends BookingDetailState {}

class BookingDetailLoading extends BookingDetailState {}

class BookingDetailLoaded extends BookingDetailState {
  final BookingDetailModel booking;

  const BookingDetailLoaded(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Emitted while cancel request is in progress (keeps current booking visible).
class BookingDetailCancelInProgress extends BookingDetailState {
  final BookingDetailModel booking;

  const BookingDetailCancelInProgress(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Emitted when cancel succeeds; UI should show message and navigate back.
class BookingDetailCancelSuccess extends BookingDetailState {
  final String bookingId;

  const BookingDetailCancelSuccess(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Emitted when cancel fails; UI can show snackbar and stay on page.
class BookingDetailCancelFailed extends BookingDetailState {
  final String message;
  final String bookingId;

  const BookingDetailCancelFailed(this.message, this.bookingId);

  @override
  List<Object?> get props => [message, bookingId];
}

class BookingDetailError extends BookingDetailState {
  final String message;

  const BookingDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
