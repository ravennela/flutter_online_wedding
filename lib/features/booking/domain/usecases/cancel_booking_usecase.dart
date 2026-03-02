import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/booking_repository_impl.dart';

class CancelBookingUseCase {
  final BookingRepository _repository;

  CancelBookingUseCase(this._repository);

  Future<Either<Failure, void>> call(String bookingId) {
    return _repository.cancelBooking(bookingId);
  }
}
