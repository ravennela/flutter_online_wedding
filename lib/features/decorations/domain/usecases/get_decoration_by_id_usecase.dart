import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/decorations/domain/models/create_decoration_model.dart';
import 'package:flutter_online/features/decorations/domain/models/decoration_detail.dart';
import '../../domain/repositories/decoration_repository.dart';

class GetDecorationByIdUseCase {
  final DecorationRepository repository;

  GetDecorationByIdUseCase(this.repository);

  Future<Either<String, DecorationDetail>> call(String id) {
    return repository.getDecorationById(id);
  }
}
