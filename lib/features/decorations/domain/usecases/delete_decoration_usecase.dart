
import 'package:dartz/dartz.dart';
import 'package:flutter_online/core/errors/failures.dart';
import 'package:flutter_online/features/decorations/domain/repositories/decoration_repository.dart';

class DeleteDecoration {
  final DecorationRepository repository;

  DeleteDecoration(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteDecoration(id);
  }
}
