class RazorpayOrderEntity {
  final String orderId;
  final String key;
  final double amount;
  final String bookingId;

  RazorpayOrderEntity({
    required this.orderId,
    required this.key,
    required this.amount,
    required this.bookingId,
  });
}

