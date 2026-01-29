import 'package:flutter_bloc/flutter_bloc.dart';
import 'event_event.dart';
import 'event_state.dart';
import '../data/repositories/event_repository_impl.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepositoryImpl eventRepository;
  
  EventBloc(this.eventRepository) : super(EventInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<LoadEventDetail>(_onLoadEventDetail);

  }
  
  Future<void> _onLoadEvents(
    LoadEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final result = await eventRepository.getEvents();
      result.fold(
        (failure) => emit(EventError(failure.message)),
        (events) => emit(EventsLoaded(events)),
      );
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }
  
  Future<void> _onLoadEventDetail(
    LoadEventDetail event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final result = await eventRepository.getEventDetail(event.eventId);
      result.fold(
        (failure) => emit(EventError(failure.message)),
        (eventModel) => emit(EventDetailLoaded(eventModel)),
      );
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }
  
}
