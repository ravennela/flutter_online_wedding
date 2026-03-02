import 'package:equatable/equatable.dart';
import '../domain/entities/razorpay_order_entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class RazorpayOrderCreated extends PaymentState {
  final RazorpayOrderEntity response;

  const RazorpayOrderCreated(this.response);

  @override
  List<Object> get props => [response];
}


class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}

class PaymentSuccess extends PaymentState {
  final String paymentId;

  const PaymentSuccess(this.paymentId);

  @override
  List<Object> get props => [paymentId];
}

class PaymentFailureState extends PaymentState {
  final String message;

  const PaymentFailureState(this.message);

  @override
  List<Object> get props => [message];
}
