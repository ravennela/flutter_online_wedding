class BookingModel {
  final String id;
  final String eventId;
  final String userId;
  final DateTime bookingDate;
  final DateTime eventDate;
  final String status;
  final double totalAmount;
  final Map<String, dynamic>? additionalData;
  
  BookingModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.bookingDate,
    required this.eventDate,
    required this.status,
    required this.totalAmount,
    this.additionalData,
  });
  
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      eventDate: DateTime.parse(json['event_date'] as String),
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      additionalData: json['additional_data'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'booking_date': bookingDate.toIso8601String(),
      'event_date': eventDate.toIso8601String(),
      'status': status,
      'total_amount': totalAmount,
      'additional_data': additionalData,
    };
  }
}
