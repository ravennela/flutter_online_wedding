import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

import '../repositories/address_repository.dart';

class DeleteAddressUseCase  {
  final AddressRepository repository;

  DeleteAddressUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String addressId) async {
    return await repository.deleteAddress(addressId);
  }
}
