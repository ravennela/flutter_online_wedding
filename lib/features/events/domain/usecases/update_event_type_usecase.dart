import 'package:dartz/dartz.dart';
import '../models/create_event_type_model.dart';
import '../repositories/event_type_repository.dart';

class UpdateEventTypeUseCase {
  final EventTypeRepository repository;

  UpdateEventTypeUseCase({required this.repository});

  Future<Either<String, CreateEventTypeModel>> call({
    required String id,
    required bool active,
    required String name,
    required String? description,
    required String? iconUrl,
    String? iconPublicId,
    required int? sortOrder,
  }) async {
    final Map<String, dynamic> data = {
      "id": id,
      "name": name,
      "description": description,
      "active": active,
      "iconUrl": iconUrl,
      "iconPublicId": iconPublicId,
      "sortOrder": sortOrder,
    };

    return await repository.updateEventTypeRepo(id, data);
  }
}
