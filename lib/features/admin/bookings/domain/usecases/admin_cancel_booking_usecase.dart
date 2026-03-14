import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_online/core/errors/failures.dart';
import '../repositories/admin_booking_repository.dart';

class AdminCancelBookingUseCase extends Equatable {
  final AdminBookingRepository repository;

  const AdminCancelBookingUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, String reason) {
    return repository.adminCancelBooking(id, reason);
  }

  @override
  List<Object?> get props => [repository];
}
