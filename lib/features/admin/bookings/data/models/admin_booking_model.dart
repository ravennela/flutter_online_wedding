import '../../domain/entities/admin_booking_entity.dart';

class AdminBookingModel extends AdminBookingEntity {
  const AdminBookingModel({
    required super.bookingId,
    super.userName,
    required super.eventType,
    required super.eventDate,
    required super.city,
    required super.totalAmount,
    required super.status,
    required super.paymentStatus,
  });

  factory AdminBookingModel.fromJson(Map<String, dynamic> json) {
    return AdminBookingModel(
      bookingId: json['bookingId'] as String,
      userName: json['userName'] as String?,
      eventType: json['eventType'] as String,
      eventDate: json['eventDate'] as String,
      city: json['city'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
    );
  }
}

class AdminBookingResponseModel extends AdminBookingListEntity {
  const AdminBookingResponseModel({
    required super.content,
    required super.totalElements,
    required super.totalPages,
    required super.number,
    required super.size,
    required super.last,
  });

  factory AdminBookingResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminBookingResponseModel(
      content: (json['content'] as List<dynamic>)
          .map((e) => AdminBookingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      number: json['number'] as int,
      size: json['size'] as int,
      last: json['last'] as bool,
    );
  }
}

class AdminBookingDetailModel extends AdminBookingDetailEntity {
  const AdminBookingDetailModel({
    required super.bookingId,
    super.bookingCode,
    super.customerName,
    super.customerEmail,
    required super.customerPhone,
    required super.eventType,
    required super.decoration,
    required super.eventDate,
    required super.city,
    required super.addressLine,
    required super.totalAmount,
    super.advanceAmount,
    required super.paymentMode,
    required super.paymentStatus,
    required super.status,
    required super.vendorName,
    super.vendorId,
    super.customerNote,
    required super.createdAt,
  });

  factory AdminBookingDetailModel.fromJson(Map<String, dynamic> json) {
    return AdminBookingDetailModel(
      bookingId: json['bookingId'] as String,
      bookingCode: json['bookingCode'] as String?,
      customerName: json['customerName'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerPhone: json['customerPhone'] as String? ?? '',
      eventType: json['eventType'] as String? ?? '',
      decoration: json['decoration'] as String? ?? '',
      eventDate: json['eventDate'] as String? ?? '',
      city: json['city'] as String? ?? '',
      addressLine: json['addressLine'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      advanceAmount: (json['advanceAmount'] as num?)?.toDouble(),
      paymentMode: json['paymentMode'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? '',
      status: json['status'] as String? ?? '',
      vendorName: json['vendorName'] as String? ?? 'Not Assigned',
      vendorId: json['vendorId'] as String?,
      customerNote: json['customerNote'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
