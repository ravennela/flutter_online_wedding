import 'package:equatable/equatable.dart';
import 'package:flutter_online/features/decorations/domain/models/city_list_item.dart';
import 'package:flutter_online/features/events/domain/models/event_type_list_item.dart';

abstract class CreateDecorationState extends Equatable {
  const CreateDecorationState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class CreateDecorationInitial extends CreateDecorationState {}

/// Loading event types and cities.
class CreateDecorationLoading extends CreateDecorationState {}

/// Form ready with event types and cities loaded.
class CreateDecorationFormReady extends CreateDecorationState {
  final List<EventTypeListItem> eventTypes;
  final List<CityListItem> cities;

  const CreateDecorationFormReady({
    required this.eventTypes,
    required this.cities,
  });

  @override
  List<Object?> get props => [eventTypes, cities];
}

/// Failed to load event types or cities.
class CreateDecorationLoadFailure extends CreateDecorationState {
  final String error;

  const CreateDecorationLoadFailure(this.error);

  @override
  List<Object?> get props => [error];
}

/// Submitting create decoration.
class CreateDecorationSubmitting extends CreateDecorationState {}

/// Create decoration success.
class CreateDecorationSubmitSuccess extends CreateDecorationState {
  final String message;

  const CreateDecorationSubmitSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Create decoration submit failure.
class CreateDecorationSubmitFailure extends CreateDecorationState {
  final String error;

  const CreateDecorationSubmitFailure(this.error);

  @override
  List<Object?> get props => [error];
}
