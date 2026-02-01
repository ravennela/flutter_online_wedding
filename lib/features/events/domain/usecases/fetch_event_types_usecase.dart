import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/events/domain/models/event_type_list_response.dart';
import 'package:flutter_online/features/events/domain/repositories/event_type_repository.dart';

class FetchEventTypesUsecase {
  final EventTypeRepository repository;

  FetchEventTypesUsecase({required this.repository});

  Future<Either<String, EventTypeListResponse>> call({
    required int page,
    required int size,
    String? search,
    bool? active,
  }) async {
    return repository.fetchEventTypesRepo(
      page: page,
      size: size,
      search: search,
      active: active,
    );
  }
}
