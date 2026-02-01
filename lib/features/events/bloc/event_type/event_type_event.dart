import 'package:equatable/equatable.dart';

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
