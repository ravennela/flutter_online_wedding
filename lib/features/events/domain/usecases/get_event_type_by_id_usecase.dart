import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/events/domain/models/event_type_list_item.dart';
import 'package:flutter_online/features/events/domain/repositories/event_type_repository.dart';

class GetEventTypeByIdUseCase {
  final EventTypeRepository repository;

  GetEventTypeByIdUseCase(this.repository);

  Future<Either<String, EventTypeListItem>> call(String id) {
    return repository.getEventTypeByIdRepo(id);
  }
}
