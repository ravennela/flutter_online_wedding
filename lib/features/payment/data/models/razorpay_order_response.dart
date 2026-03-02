import 'package:flutter_online/features/payment/domain/entities/razorpay_order_entity.dart';

class RazorpayOrderResponse extends RazorpayOrderEntity {
  RazorpayOrderResponse({
    required super.orderId,
    required super.key,
    required super.amount,
    required super.bookingId,
  });

  /// Backend returns: orderId, keyId, amount (in paise). bookingId is not in response; pass from request.
  factory RazorpayOrderResponse.fromJson(Map<String, dynamic> json, {required String bookingId}) {
    return RazorpayOrderResponse(
      orderId: (json['orderId'] ?? json['order_id']) as String,
      key: (json['keyId'] ?? json['key']) as String,
      amount: (json['amount'] as num).toDouble(),
      bookingId: bookingId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'key': key,
      'amount': amount,
      'booking_id': bookingId,
    };
  }
}


