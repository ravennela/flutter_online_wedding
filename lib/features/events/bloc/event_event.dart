import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();
  
  @override
  List<Object> get props => [];
}

class LoadEvents extends EventEvent {
  const LoadEvents();
}

class LoadEventDetail extends EventEvent {
  final String eventId;
  
  const LoadEventDetail(this.eventId);
  
  @override
  List<Object> get props => [eventId];
}

class LoadDecorationDetail extends EventEvent {
  final String decorationId;
  
  const LoadDecorationDetail(this.decorationId);
  
  @override
  List<Object> get props => [decorationId];
}
