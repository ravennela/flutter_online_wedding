import 'package:flutter/material.dart';

enum BookingStatus {
  requested,
  approved,
  confirmed,
  cancelled,
}

enum PaymentStatus {
  pending,
  initiated,
  success,
  failed,
  refunded,
}

class AdminBookingUIModel {
  final String id;
  final String bookingCode;
  final String customerName;
  final String eventType;
  final DateTime eventDate;
  final String city;
  final double amount;
  final BookingStatus bookingStatus;
  final PaymentStatus paymentStatus;
  final String? vendorName;

  AdminBookingUIModel({
    required this.id,
    required this.bookingCode,
    required this.customerName,
    required this.eventType,
    required this.eventDate,
    required this.city,
    required this.amount,
    required this.bookingStatus,
    required this.paymentStatus,
    this.vendorName,
  });

  bool get isCancelled => bookingStatus == BookingStatus.cancelled;
  bool get hasVendor => vendorName != null && vendorName!.isNotEmpty;
  bool get isRefundable => paymentStatus == PaymentStatus.success && !isCancelled;
}

class BookingStatsModel {
  final String label;
  final String value;
  final double percentage;
  final bool isIncrease;
  final Color color;
  final double progress;

  BookingStatsModel({
    required this.label,
    required this.value,
    required this.percentage,
    required this.isIncrease,
    required this.color,
    required this.progress,
  });
}
