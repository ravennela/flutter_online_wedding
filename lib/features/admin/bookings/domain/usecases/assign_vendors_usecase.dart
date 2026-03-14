import 'package:dartz/dartz.dart';
import 'package:flutter_online/core/errors/failures.dart';
import '../repositories/admin_booking_repository.dart';

class AssignVendorsUseCase {
  final AdminBookingRepository repository;

  AssignVendorsUseCase(this.repository);

  Future<Either<Failure, void>> call(String bookingId, List<String> vendorIds) async {
    return await repository.assignVendors(bookingId, vendorIds);
  }
}
