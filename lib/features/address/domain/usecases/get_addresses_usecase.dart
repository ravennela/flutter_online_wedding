import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/address_entity.dart';
import '../repositories/address_repository.dart';

class GetAddressesUseCase {
  final AddressRepository repository;

  GetAddressesUseCase(this.repository);

  Future<Either<Failure, List<AddressEntity>>> call(String userId) {
    return repository.getMyAddresses(userId);
  }
}
