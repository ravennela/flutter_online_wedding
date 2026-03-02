import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_online/core/errors/failures.dart';

import '../entities/admin_booking_entity.dart';
import '../repositories/admin_booking_repository.dart';

class GetAdminBookingsUseCase {
  final AdminBookingRepository repository;

  GetAdminBookingsUseCase(this.repository);

  Future<Either<Failure, AdminBookingListEntity>> call(AdminBookingParams params) {
    return repository.getAdminBookings(
      page: params.page,
      size: params.size,
      status: params.status,
      city: params.city,
      paymentStatus: params.paymentStatus,
    );
  }
}

class AdminBookingParams extends Equatable {
  final int page;
  final int size;
  final String? status;
  final String? city;
  final String? paymentStatus;

  const AdminBookingParams({
    required this.page,
    required this.size,
    this.status,
    this.city,
    this.paymentStatus,
  });

  @override
  List<Object?> get props => [page, size, status, city, paymentStatus];
}
