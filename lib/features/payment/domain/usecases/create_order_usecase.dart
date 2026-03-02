import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/razorpay_order_entity.dart';
import '../repositories/payment_repository.dart';

class CreateOrderUseCase {
  final PaymentRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, RazorpayOrderEntity>> call(String bookingId, double amountInRupees) {
    return repository.createOrder(bookingId, amountInRupees);
  }
}
