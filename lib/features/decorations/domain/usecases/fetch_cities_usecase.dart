import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/decorations/domain/models/city_list_item.dart';
import 'package:flutter_online/features/decorations/domain/repositories/decoration_repository.dart';

class FetchCitiesUsecase {
  final DecorationRepository repository;

  FetchCitiesUsecase({required this.repository});

  Future<Either<String, List<CityListItem>>> call({
    int page = 0,
    int size = 100,
  }) async {
    return repository.fetchCities(page: page, size: size);
  }
}
