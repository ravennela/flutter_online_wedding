import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/events/domain/models/create_event_type_model.dart';
import 'package:flutter_online/features/events/domain/models/event_type_list_item.dart';
import 'package:flutter_online/features/events/domain/models/event_type_list_response.dart';

abstract class EventTypeRepository {
  /// ➕ Create Event Type (ADMIN)
  Future<Either<String, CreateEventTypeModel>> createEventTypeRepo(
    Map<String, dynamic> data,
  );

  /// 📄 Fetch Event Types (Admin list with search & pagination)
  Future<Either<String, EventTypeListResponse>> fetchEventTypesRepo({
    required int page,
    required int size,
    String? search,
    bool? active,
  });

  /// ✏️ Update Event Type (e.g. Soft Delete)
  Future<Either<String, CreateEventTypeModel>> updateEventTypeRepo(
    String id,
    Map<String, dynamic> data,
  );

  /// 📄 Get Single Event Type by ID
  Future<Either<String, EventTypeListItem>> getEventTypeByIdRepo(String id);
}
