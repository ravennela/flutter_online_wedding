import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/address_entity.dart';
import '../repositories/address_repository.dart';

class CreateAddressUseCase {
  final AddressRepository repository;

  CreateAddressUseCase(this.repository);

  Future<Either<Failure, AddressEntity>> call(AddressEntity address, String userId) {
    return repository.createAddress(address, userId);
  }
}
