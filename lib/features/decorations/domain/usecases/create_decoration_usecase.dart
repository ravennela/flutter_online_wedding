import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/decorations/domain/models/create_decoration_model.dart';
import 'package:flutter_online/features/decorations/domain/repositories/decoration_repository.dart';

class CreateDecorationUsecase {
  final DecorationRepository repository;

  CreateDecorationUsecase({required this.repository});

  Future<Either<String, CreateDecorationModel>> call({
    required String eventTypeId,
    required String cityId,
    required String name,
    String? description,
    String? inclusions,
    String? exclusions,
    required int basePrice,
    List<String>? imageUrls,
    bool active = true,
  }) async {
    final data = <String, dynamic>{
      'eventTypeId': eventTypeId,
      'cityId': cityId,
      'name': name,
      'description': description ?? '',
      'inclusions': inclusions ?? '',
      'exclusions': exclusions ?? '',
      'basePrice': basePrice,
      'imageUrls': imageUrls ?? [],
      'active': active,
    };
    return repository.createDecoration(data);
  }
}
