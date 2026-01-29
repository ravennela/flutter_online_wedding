import 'package:equatable/equatable.dart';
import '../data/models/event_model.dart';
import '../data/models/decoration_model.dart';

abstract class EventState extends Equatable {
  const EventState();
  
  @override
  List<Object> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventsLoaded extends EventState {
  final List<EventModel> events;
  
  const EventsLoaded(this.events);
  
  @override
  List<Object> get props => [events];
}

class EventDetailLoaded extends EventState {
  final EventModel event;
  
  const EventDetailLoaded(this.event);
  
  @override
  List<Object> get props => [event];
}

class DecorationDetailLoaded extends EventState {
  final DecorationModel decoration;
  
  const DecorationDetailLoaded(this.decoration);
  
  @override
  List<Object> get props => [decoration];
}

class EventError extends EventState {
  final String message;
  
  const EventError(this.message);
  
  @override
  List<Object> get props => [message];
}
