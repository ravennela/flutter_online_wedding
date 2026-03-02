import 'package:dartz/dartz.dart';
import 'package:flutter_online/core/errors/failures.dart';

import '../entities/admin_booking_entity.dart';

abstract class AdminBookingRepository {
  Future<Either<Failure, AdminBookingListEntity>> getAdminBookings({
    required int page,
    required int size,
    String? status,
    String? city,
    String? paymentStatus,
  });
}
