import 'package:flutter/material.dart';

class AdminBookingUIModel {
  final String id;
  final String bookingCode;
  final String customerName;
  final String email;
  final String phone;
  final String company;
  final String eventName;
  final String eventType;
  final DateTime eventDate;
  final int guestCount;
  final String venue;
  final String address;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String paymentStatus;
  final String city;
  final String? vendorId;
  final DateTime createdAt;

  AdminBookingUIModel({
    required this.id,
    required this.bookingCode,
    required this.customerName,
    required this.email,
    required this.phone,
    this.company = '',
    required this.eventName,
    required this.eventType,
    required this.eventDate,
    this.guestCount = 0,
    required this.venue,
    required this.address,
    required this.city,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.paymentStatus,
    this.vendorId,
    required this.createdAt,
  });

  double get dueBalance => totalAmount - paidAmount;
  bool get isCancelled => status.toUpperCase() == 'CANCELLED';
  bool get isRefundable => paymentStatus.toUpperCase() == 'SUCCESS';

  factory AdminBookingUIModel.fromEntity(dynamic entity) {
    // If it's already the UI model, return it (for mock safety)
    if (entity is AdminBookingUIModel) return entity;
    
    // Otherwise map from AdminBookingDetailEntity
    return AdminBookingUIModel(
      id: entity.bookingId,
      bookingCode: entity.bookingCode ?? 'BK-${entity.bookingId.substring(0, 5).toUpperCase()}',
      customerName: entity.customerName ?? 'System User',
      email: entity.customerEmail ?? 'N/A',
      phone: entity.customerPhone,
      company: '', // Placeholder as API doesn't provide it
      eventName: entity.decoration,
      eventType: entity.eventType,
      eventDate: DateTime.parse(entity.eventDate),
      guestCount: 0, // Placeholder
      venue: entity.decoration, // Using decoration name as venue since venue field is missing in JSON
      address: entity.addressLine,
      city: entity.city,
      totalAmount: entity.totalAmount,
      paidAmount: entity.advanceAmount ?? 0.0,
      status: entity.status,
      paymentStatus: entity.paymentStatus,
      vendorId: entity.vendorId,
      createdAt: DateTime.tryParse(entity.createdAt) ?? DateTime.now(),
    );
  }
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

class VendorModel {
  final String id;
  final String name;
  final String category;
  final String status;
  final String? avatarUrl;

  VendorModel({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    this.avatarUrl,
  });
}

class ActivityModel {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final IconData icon;

  ActivityModel({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
  });
}
