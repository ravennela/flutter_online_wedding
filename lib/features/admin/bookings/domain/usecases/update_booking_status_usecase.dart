import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_online/core/errors/failures.dart';
import '../repositories/admin_booking_repository.dart';

class UpdateBookingStatusUseCase extends Equatable {
  final AdminBookingRepository repository;

  const UpdateBookingStatusUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, String status) {
    return repository.updateBookingStatus(id, status);
  }

  @override
  List<Object?> get props => [repository];
}
