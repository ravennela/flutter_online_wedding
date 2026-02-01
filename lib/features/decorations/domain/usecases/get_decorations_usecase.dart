import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/decorations/domain/models/decoration_list_response.dart';
import 'package:flutter_online/features/decorations/domain/repositories/decoration_repository.dart';

class GetDecorationsUseCase {
  final DecorationRepository repository;

  GetDecorationsUseCase(this.repository);

  Future<Either<String, DecorationListResponse>> call({
    int page = 0,
    int size = 10,
    String? search,
    String? cityId,
    String? eventTypeId,
    bool? active,
    String? sortBy,
    String? sortDir,
  }) {
    return repository.fetchDecorations(
      page: page,
      size: size,
      search: search,
      cityId: cityId,
      eventTypeId: eventTypeId,
      active: active,
      sortBy: sortBy,
      sortDir: sortDir,
    );
  }
}
