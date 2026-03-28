import 'package:dartz/dartz.dart';
import 'package:flutter_online/core/errors/exceptions.dart';
import 'package:flutter_online/core/errors/failures.dart';

import '../../domain/entities/admin_booking_entity.dart';
import '../../domain/repositories/admin_booking_repository.dart';
import '../datasources/admin_booking_remote_datasource.dart';

class AdminBookingRepositoryImpl implements AdminBookingRepository {
  final AdminBookingRemoteDataSource remoteDataSource;

  AdminBookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AdminBookingListEntity>> getAdminBookings({
    required int page,
    required int size,
    String? status,
    String? city,
    String? paymentStatus,
    String? search,
    String? startDate,
    String? endDate,
    String? eventTypeId,
  }) async {
    try {
      final result = await remoteDataSource.getAdminBookings(
        page: page,
        size: size,
        status: status,
        city: city,
        paymentStatus: paymentStatus,
        search: search,
        startDate: startDate,
        endDate: endDate,
        eventTypeId: eventTypeId,
      );


      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminBookingDetailEntity>> getAdminBookingDetail(String id) async {
    try {
      final result = await remoteDataSource.getAdminBookingDetail(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBookingStatus(String id, String status) async {
    try {
      await remoteDataSource.updateBookingStatus(id, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> adminCancelBooking(String id, String reason) async {
    try {
      await remoteDataSource.adminCancelBooking(id, reason);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, void>> assignVendors(String bookingId, List<String> vendorIds) async {
    try {
      await remoteDataSource.assignVendors(bookingId, vendorIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deAssignVendor(String bookingId, String vendorId) async {
    try {
      await remoteDataSource.deAssignVendor(bookingId, vendorId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBookingDetail(String id, Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateBookingDetail(id, data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
