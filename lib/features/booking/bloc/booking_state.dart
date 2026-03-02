import 'package:equatable/equatable.dart';
import '../data/models/booking_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingsLoaded extends BookingState {
  final List<BookingModel> bookings;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  const BookingsLoaded({
    required this.bookings,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  BookingsLoaded copyWith({
    List<BookingModel>? bookings,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return BookingsLoaded(
      bookings: bookings ?? this.bookings,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [bookings, hasMore, currentPage, isLoadingMore];
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
