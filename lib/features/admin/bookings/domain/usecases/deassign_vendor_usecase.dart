import 'package:dartz/dartz.dart';
import 'package:flutter_online/core/errors/failures.dart';
import '../repositories/admin_booking_repository.dart';

class DeAssignVendorUseCase {
  final AdminBookingRepository repository;

  DeAssignVendorUseCase(this.repository);

  Future<Either<Failure, void>> call(String bookingId, String vendorId) async {
    return await repository.deAssignVendor(bookingId, vendorId);
  }
}
