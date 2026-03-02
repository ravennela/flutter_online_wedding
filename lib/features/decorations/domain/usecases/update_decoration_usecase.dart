import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/decorations/domain/models/create_decoration_model.dart';
import 'package:flutter_online/features/decorations/domain/repositories/decoration_repository.dart';

class UpdateDecorationUseCase {
  final DecorationRepository repository;

  UpdateDecorationUseCase({required this.repository});

  Future<Either<String, CreateDecorationModel>> call({
    required String id,
    required String eventTypeId,
    required String cityId,
    required String name,
    String? description,
    String? inclusions,
    String? exclusions,
    required int basePrice,
    bool active = true,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'description': description ?? '',
      'inclusions': inclusions ?? '',
      'exclusions': exclusions ?? '',
      'basePrice': basePrice,
      'cityId': cityId,
      'eventTypeId': eventTypeId,
      'active': active,
    };
    return repository.updateDecoration(id, data);
  }
}
