import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/booking_page_result.dart';
import '../../data/repositories/booking_repository_impl.dart';

/// Use case: fetch paginated list of current user's bookings.
class GetMyBookingsUseCase {
  final BookingRepository _repository;

  GetMyBookingsUseCase(this._repository);

  Future<Either<Failure, BookingPageResult>> call(int page, int size) {
    return _repository.getMyBookingsPage(page, size);
  }
}
