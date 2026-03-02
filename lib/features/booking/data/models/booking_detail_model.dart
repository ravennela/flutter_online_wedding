/// API response for GET /api/bookings/:id – full booking detail with payment and address.
class BookingDetailModel {
  final String bookingId;
  final String eventTitle;
  final String eventType;
  final String eventDate; // ISO date or date-time string
  final String bookingStatus;
  final String paymentStatus;
  final double totalAmount;
  final String paymentMode;
  final String bookingCreatedAt; // ISO date-time
  final int? guestCount;
  final BookingDetailPaymentModel? payment;
  final BookingDetailAddressModel? address;

  const BookingDetailModel({
    required this.bookingId,
    required this.eventTitle,
    required this.eventType,
    required this.eventDate,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.totalAmount,
    required this.paymentMode,
    required this.bookingCreatedAt,
    this.guestCount,
    this.payment,
    this.address,
  });

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailModel(
      bookingId: json['bookingId'] as String? ?? '',
      eventTitle: json['eventTitle'] as String? ?? '',
      eventType: json['eventType'] as String? ?? '',
      eventDate: json['eventDate'] as String? ?? '',
      bookingStatus: json['bookingStatus'] as String? ?? 'REQUESTED',
      paymentStatus: json['paymentStatus'] as String? ?? 'PENDING',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      paymentMode: json['paymentMode'] as String? ?? 'ONLINE',
      bookingCreatedAt: json['bookingCreatedAt'] as String? ?? '',
      guestCount: json['guestCount'] as int?,
      payment: json['payment'] != null
          ? BookingDetailPaymentModel.fromJson(
              json['payment'] as Map<String, dynamic>)
          : null,
      address: json['address'] != null
          ? BookingDetailAddressModel.fromJson(
              json['address'] as Map<String, dynamic>)
          : null,
    );
  }
}

class BookingDetailPaymentModel {
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? paymentStatus;
  final String? paymentMode;

  const BookingDetailPaymentModel({
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.paymentStatus,
    this.paymentMode,
  });

  factory BookingDetailPaymentModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailPaymentModel(
      razorpayOrderId: json['razorpayOrderId'] as String?,
      razorpayPaymentId: json['razorpayPaymentId'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      paymentMode: json['paymentMode'] as String?,
    );
  }
}

class BookingDetailAddressModel {
  final String? venueName;
  final String? fullAddress;
  final String? city;
  final String? state;
  final String? pincode;

  const BookingDetailAddressModel({
    this.venueName,
    this.fullAddress,
    this.city,
    this.state,
    this.pincode,
  });

  factory BookingDetailAddressModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailAddressModel(
      venueName: json['venueName'] as String?,
      fullAddress: json['fullAddress'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
    );
  }

  /// Single line for display (e.g. "fullAddress, city state pincode").
  String get displayLine {
    final parts = <String>[];
    if (fullAddress != null && fullAddress!.isNotEmpty) parts.add(fullAddress!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (pincode != null && pincode!.isNotEmpty) parts.add(pincode!);
    return parts.join(', ');
  }
}
