import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/address_entity.dart';

abstract class AddressRepository {
  Future<Either<Failure, AddressEntity>> createAddress(
    AddressEntity address,
    String userId,
  );

  Future<Either<Failure, List<AddressEntity>>> getMyAddresses(String userId);

  Future<Either<Failure, Unit>> deleteAddress(String addressId);
}
