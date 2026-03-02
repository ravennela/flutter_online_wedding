class BookingModel {
  final String bookingId;
  final String eventType;
  final String decorationTitle;
  final String city;
  final DateTime eventDate;
  final String status;
  final String? paymentStatus;
  final double totalAmount;
  final DateTime createdAt;
  final String? fullAddress;
  final String? customerNote;
  final String? razorpayOrderId;

  BookingModel({
    required this.bookingId,
    required this.eventType,
    required this.decorationTitle,
    required this.city,
    required this.eventDate,
    required this.status,
    this.paymentStatus,
    required this.totalAmount,
    required this.createdAt,
    this.fullAddress,
    this.customerNote,
    this.razorpayOrderId,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final eventDateStr = json['eventDate'] as String?;
    final createdAtStr = json['createdAt'] as String?;
    return BookingModel(
      bookingId: json['bookingId'] as String,
      eventType: json['eventType'] as String? ?? '',
      decorationTitle: json['decorationTitle'] as String? ?? '',
      city: json['city'] as String? ?? '',
      eventDate: eventDateStr != null
          ? (eventDateStr.length > 10
              ? DateTime.parse(eventDateStr)
              : DateTime.parse('$eventDateStr'))
          : DateTime.now(),
      status: json['status'] as String? ?? 'REQUESTED',
      paymentStatus: json['paymentStatus'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      createdAt: createdAtStr != null ? DateTime.parse(createdAtStr) : DateTime.now(),
      fullAddress: json['fullAddress'] as String?,
      customerNote: json['customerNote'] as String?,
      razorpayOrderId: json['razorpayOrderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'eventType': eventType,
      'decorationTitle': decorationTitle,
      'city': city,
      'eventDate': eventDate.toIso8601String(),
      'status': status,
      'paymentStatus': paymentStatus,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'fullAddress': fullAddress,
      'customerNote': customerNote,
      'razorpayOrderId': razorpayOrderId,
    };
  }
}