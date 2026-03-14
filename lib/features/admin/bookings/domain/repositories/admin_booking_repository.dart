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

  Future<Either<Failure, AdminBookingDetailEntity>> getAdminBookingDetail(String id);
  Future<Either<Failure, void>> updateBookingStatus(String id, String status);
  Future<Either<Failure, void>> adminCancelBooking(String id, String reason);
  Future<Either<Failure, void>> assignVendors(String bookingId, List<String> vendorIds);
  Future<Either<Failure, void>> deAssignVendor(String bookingId, String vendorId);
}
