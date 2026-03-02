import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/razorpay_order_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../sources/payment_remote_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteSource remoteSource;

  PaymentRepositoryImpl(this.remoteSource);

  @override
  Future<Either<Failure, RazorpayOrderEntity>> createOrder(String bookingId, double amountInRupees) async {
    try {
      final response = await remoteSource.createOrder(bookingId, amountInRupees);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
