import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_online/core/errors/failures.dart';
import '../entities/admin_booking_entity.dart';
import '../repositories/admin_booking_repository.dart';

class GetAdminBookingDetailUseCase extends Equatable {
  final AdminBookingRepository repository;

  const GetAdminBookingDetailUseCase(this.repository);

  Future<Either<Failure, AdminBookingDetailEntity>> call(String id) {
    return repository.getAdminBookingDetail(id);
  }

  @override
  List<Object?> get props => [repository];
}
