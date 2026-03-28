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

class AdminBookingDetailEntity extends Equatable {
  final String bookingId;
  final String? bookingCode;
  final String? customerName;
  final String? customerEmail;
  final String customerPhone;
  final String eventType;
  final String decoration;
  final String? decorationId;
  final String eventDate;
  final String city;
  final String addressLine;
  final double totalAmount;
  final double? advanceAmount;
  final String paymentMode;
  final String paymentStatus;
  final String status;
  final String vendorName;
  final String? vendorId;
  final String? customerNote;
  final String createdAt;
  final List<Map<String, String>> assignedVendors;

  const AdminBookingDetailEntity({
    required this.bookingId,
    this.bookingCode,
    this.customerName,
    this.customerEmail,
    required this.customerPhone,
    required this.eventType,
    required this.decoration,
    this.decorationId,
    required this.eventDate,
    required this.city,
    required this.addressLine,
    required this.totalAmount,
    this.advanceAmount,
    required this.paymentMode,
    required this.paymentStatus,
    required this.status,
    required this.vendorName,
    this.vendorId,
    this.customerNote,
    required this.createdAt,
    required this.assignedVendors,
  });

  @override
  List<Object?> get props => [
        bookingId,
        bookingCode,
        customerName,
        customerEmail,
        customerPhone,
        eventType,
        decoration,
        decorationId,
        eventDate,
        city,
        addressLine,
        totalAmount,
        advanceAmount,
        paymentMode,
        paymentStatus,
        status,
        vendorName,
        vendorId,
        customerNote,
        createdAt,
        assignedVendors,
      ];
}
