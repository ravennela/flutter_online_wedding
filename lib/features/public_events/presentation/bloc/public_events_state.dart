import 'package:equatable/equatable.dart';
import 'package:flutter_online/features/public_events/domain/models/public_event_item.dart';

abstract class PublicEventsState extends Equatable {
  const PublicEventsState();

  @override
  List<Object?> get props => [];
}

class PublicEventsInitial extends PublicEventsState {
  const PublicEventsInitial();
}

class PublicEventsLoading extends PublicEventsState {
  const PublicEventsLoading();
}

class PublicEventsLoaded extends PublicEventsState {
  final List<PublicEventItem> events;

  const PublicEventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class PublicEventsFailure extends PublicEventsState {
  final String message;

  const PublicEventsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
