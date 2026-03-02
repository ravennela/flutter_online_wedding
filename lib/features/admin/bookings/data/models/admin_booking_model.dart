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
