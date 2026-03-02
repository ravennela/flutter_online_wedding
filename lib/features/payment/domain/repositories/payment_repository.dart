import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/razorpay_order_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, RazorpayOrderEntity>> createOrder(String bookingId, double amountInRupees);
}
