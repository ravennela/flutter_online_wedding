import 'package:equatable/equatable.dart';
import '../../domain/models/event_type_list_item.dart';

abstract class EventTypeEvent extends Equatable {
  const EventTypeEvent();

  @override
  List<Object?> get props => [];
}

/// ➕ Trigger create event type
class SubmitCreateEventType extends EventTypeEvent {
  final String name;
  final String? description;
  final String? iconUrl;
  final int? sortOrder;

  const SubmitCreateEventType({
    required this.name,
    this.description,
    this.iconUrl,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [name, description, iconUrl, sortOrder];
}

/// 📄 Fetch event types list (with search, pagination, status filter)
class FetchEventTypes extends EventTypeEvent {
  final int page;
  final int size;
  final String? search;
  final bool? active;

  const FetchEventTypes({
    this.page = 0,
    this.size = 10,
    this.search,
    this.active,
  });

  @override
  List<Object?> get props => [page, size, search, active];
}

/// 🗑️ Soft Delete Event Type (update active = false)
class DeleteEventType extends EventTypeEvent {
  final EventTypeListItem item;

  const DeleteEventType(this.item);


  @override
  List<Object?> get props => [item];
}

/// 📄 Get Single Event Type by ID
class GetEventTypeByIdEvent extends EventTypeEvent {
  final String id;

  const GetEventTypeByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// ✏️ Update Event Type (Full update)
class UpdateEventType extends EventTypeEvent {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final bool active;
  final int? sortOrder;

  const UpdateEventType({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.active,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [id, name, description, iconUrl, active, sortOrder];
}
