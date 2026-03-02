import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/booking_detail_model.dart';
import '../../data/repositories/booking_repository_impl.dart';

class GetBookingDetailUseCase {
  final BookingRepository _repository;

  GetBookingDetailUseCase(this._repository);

  Future<Either<Failure, BookingDetailModel>> call(String bookingId) {
    return _repository.getBookingDetail(bookingId);
  }
}
