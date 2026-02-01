import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/events/domain/usecases/event_type_usecase.dart';
import 'package:flutter_online/features/events/domain/usecases/fetch_event_types_usecase.dart';
import 'event_type_event.dart';
import 'event_type_state.dart';

class EventTypeBloc extends Bloc<EventTypeEvent, EventTypeState> {
  final CreateEventTypeUsecase createEventTypeUsecase;
  final FetchEventTypesUsecase fetchEventTypesUsecase;

  EventTypeBloc({
    required this.createEventTypeUsecase,
    required this.fetchEventTypesUsecase,
  }) : super(CreateEventTypeInitial()) {
    on<SubmitCreateEventType>(_onCreateEventType);
    on<FetchEventTypes>(_onFetchEventTypes);
  }

  Future<void> _onCreateEventType(
    SubmitCreateEventType event,
    Emitter<EventTypeState> emit,
  ) async {
    emit(CreateEventTypeLoading());

    final result = await createEventTypeUsecase(
      name: event.name,
      description: event.description,
      iconUrl: event.iconUrl,
      sortOrder: event.sortOrder,
    );

    result.fold(
      (error) => emit(CreateEventTypeFailure(error)),
      (success) => emit(CreateEventTypeSuccess(success.name)),
    );
  }

  Future<void> _onFetchEventTypes(
    FetchEventTypes event,
    Emitter<EventTypeState> emit,
  ) async {
    emit(EventTypesListLoading());

    final result = await fetchEventTypesUsecase(
      page: event.page,
      size: event.size,
      search: event.search,
      active: event.active,
    );

    result.fold(
      (error) => emit(EventTypesListFailure(error)),
      (response) => emit(EventTypesListLoaded(
        content: response.content,
        last: response.last,
        page: response.page,
        size: response.size,
        totalElements: response.totalElements,
        totalPages: response.totalPages,
        search: event.search,
        active: event.active,
      )),
    );
  }
}
