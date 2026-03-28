import 'package:dartz/dartz.dart';
import 'package:flutter_online/core/errors/failures.dart';
import '../repositories/admin_booking_repository.dart';

class UpdateBookingDetailUseCase {
  final AdminBookingRepository repository;

  UpdateBookingDetailUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, Map<String, dynamic> data) async {
    return await repository.updateBookingDetail(id, data);
  }
}
