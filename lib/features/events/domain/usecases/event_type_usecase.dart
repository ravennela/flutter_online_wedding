
import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/events/domain/models/create_event_type_model.dart';
import 'package:flutter_online/features/events/domain/repositories/event_type_repository.dart';

class CreateEventTypeUsecase {
  final EventTypeRepository repository;

  CreateEventTypeUsecase({required this.repository});

  Future<Either<String, CreateEventTypeModel>> call({
    required String name,
    String? description,
    String? iconUrl,
    int? sortOrder,
  }) async {
    final Map<String, dynamic> data = {
      "name": name,
      "description": description ?? "",
      "iconUrl": iconUrl ?? "",
      "sortOrder": sortOrder ?? 1,
    };

    return await repository.createEventTypeRepo(data);
  }
}
