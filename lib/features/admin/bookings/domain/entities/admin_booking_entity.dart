import 'package:equatable/equatable.dart';

class AdminBookingEntity extends Equatable {
  final String bookingId;
  final String? userName;
  final String eventType;
  final String eventDate;
  final String city;
  final double totalAmount;
  final String status;
  final String paymentStatus;

  const AdminBookingEntity({
    required this.bookingId,
    this.userName,
    required this.eventType,
    required this.eventDate,
    required this.city,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
  });

  @override
  List<Object?> get props => [
        bookingId,
        userName,
        eventType,
        eventDate,
        city,
        totalAmount,
        status,
        paymentStatus,
      ];
}

class AdminBookingListEntity extends Equatable {
  final List<AdminBookingEntity> content;
  final int totalElements;
  final int totalPages;
  final int number;
  final int size;
  final bool last;

  const AdminBookingListEntity({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.size,
    required this.last,
  });

  @override
  List<Object?> get props => [content, totalElements, totalPages, number, size, last];
}
