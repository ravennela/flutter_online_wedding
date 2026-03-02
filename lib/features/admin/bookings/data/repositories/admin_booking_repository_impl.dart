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
  }) async {
    try {
      final result = await remoteDataSource.getAdminBookings(
        page: page,
        size: size,
        status: status,
        city: city,
        paymentStatus: paymentStatus,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
