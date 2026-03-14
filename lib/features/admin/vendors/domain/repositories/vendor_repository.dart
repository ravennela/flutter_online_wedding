import 'package:dartz/dartz.dart';
import 'package:flutter_online/core/errors/failures.dart';
import '../entities/vendor_entity.dart';

abstract class VendorRepository {
  Future<Either<Failure, List<VendorEntity>>> getVendors({String? bookingId});
}
