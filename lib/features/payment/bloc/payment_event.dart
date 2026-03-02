import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class CreateRazorpayOrder extends PaymentEvent {
  final String bookingId;
  final double amountInRupees;

  const CreateRazorpayOrder({
    required this.bookingId,
    required this.amountInRupees,
  });

  @override
  List<Object> get props => [bookingId, amountInRupees];
}

