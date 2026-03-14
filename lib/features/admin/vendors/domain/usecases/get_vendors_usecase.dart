import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/vendor_entity.dart';
import '../repositories/vendor_repository.dart';

class GetVendorsUseCase {
  final VendorRepository repository;

  GetVendorsUseCase({required this.repository});

  Future<Either<Failure, List<VendorEntity>>> call({String? bookingId}) async {
    return await repository.getVendors(bookingId: bookingId);
  }
}
