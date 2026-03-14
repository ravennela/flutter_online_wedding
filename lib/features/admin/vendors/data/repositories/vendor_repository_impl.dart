import 'package:dartz/dartz.dart';
import 'package:flutter_online/core/errors/failures.dart';
import '../../domain/entities/vendor_entity.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../datasources/vendor_remote_datasource.dart';

class VendorRepositoryImpl implements VendorRepository {
  final VendorRemoteDataSource remoteDataSource;

  VendorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<VendorEntity>>> getVendors({String? bookingId}) async {
    try {
      final vendors = await remoteDataSource.getVendors(bookingId: bookingId);
      return Right(vendors);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
