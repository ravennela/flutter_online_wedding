import 'package:equatable/equatable.dart';
import 'package:flutter_online/features/events/domain/models/event_type_list_item.dart';

abstract class EventTypeState extends Equatable {
  const EventTypeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CreateEventTypeInitial extends EventTypeState {}

/// Loading while create API is in progress
class CreateEventTypeLoading extends EventTypeState {}

/// Success after creating event type
class CreateEventTypeSuccess extends EventTypeState {
  final String message;

  const CreateEventTypeSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state for create
class CreateEventTypeFailure extends EventTypeState {
  final String error;

  const CreateEventTypeFailure(this.error);

  @override
  List<Object?> get props => [error];
}

/// Loading while update API is in progress
class UpdateEventTypeLoading extends EventTypeState {}

/// Success after updating event type
class UpdateEventTypeSuccess extends EventTypeState {
  final String message;

  const UpdateEventTypeSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state for update
class UpdateEventTypeFailure extends EventTypeState {
  final String error;

  const UpdateEventTypeFailure(this.error);

  @override
  List<Object?> get props => [error];
}

/// Loading event types list
class EventTypesListLoading extends EventTypeState {}

/// Loaded event types list with pagination
class EventTypesListLoaded extends EventTypeState {
  final List<EventTypeListItem> content;
  final bool last;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final String? search;
  final bool? active;

  const EventTypesListLoaded({
    required this.content,
    required this.last,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    this.search,
    this.active,
  });

  @override
  List<Object?> get props =>
      [content, last, page, size, totalElements, totalPages, search, active];
}

/// Error state for list fetch
class EventTypesListFailure extends EventTypeState {
  final String error;

  const EventTypesListFailure(this.error);

  @override
  List<Object?> get props => [error];
}

/// Success after deleting (soft delete) event type
class EventTypeDeleteSuccess extends EventTypeState {
  final String message;

  const EventTypeDeleteSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Loading event type detail
class EventTypeDetailLoading extends EventTypeState {}

/// Loaded event type detail
class EventTypeDetailLoaded extends EventTypeState {
  final EventTypeListItem eventType;

  const EventTypeDetailLoaded(this.eventType);

  @override
  List<Object?> get props => [eventType];
}

/// Error state for detail fetch
class EventTypeDetailFailure extends EventTypeState {
  final String error;

  const EventTypeDetailFailure(this.error);

  @override
  List<Object?> get props => [error];
}
