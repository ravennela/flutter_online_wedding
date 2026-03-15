import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/events/domain/usecases/event_type_usecase.dart';
import 'package:flutter_online/features/events/domain/usecases/fetch_event_types_usecase.dart';
import 'package:flutter_online/features/events/domain/usecases/update_event_type_usecase.dart';
import 'package:flutter_online/features/events/domain/usecases/get_event_type_by_id_usecase.dart';
import 'event_type_event.dart';
import 'event_type_state.dart';

class EventTypeBloc extends Bloc<EventTypeEvent, EventTypeState> {
  final CreateEventTypeUsecase createEventTypeUsecase;
  final FetchEventTypesUsecase fetchEventTypesUsecase;
  final UpdateEventTypeUseCase updateEventTypeUsecase;
  final GetEventTypeByIdUseCase getEventTypeByIdUseCase;

  EventTypeBloc({
    required this.createEventTypeUsecase,
    required this.fetchEventTypesUsecase,
    required this.updateEventTypeUsecase,
    required this.getEventTypeByIdUseCase,
  }) : super(CreateEventTypeInitial()) {
    on<SubmitCreateEventType>(_onCreateEventType);
    on<FetchEventTypes>(_onFetchEventTypes);
    on<DeleteEventType>(_onDeleteEventType);
    on<GetEventTypeByIdEvent>(_onGetEventTypeById);
    on<UpdateEventType>(_onUpdateEventType);
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
      iconPublicId: event.iconPublicId,
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

  Future<void> _onDeleteEventType(
    DeleteEventType event,
    Emitter<EventTypeState> emit,
  ) async {
    emit(EventTypesListLoading()); // reusing loading state usually meant for list, or specific action loading

    final result = await updateEventTypeUsecase(
      id: event.item.id,
      name: event.item.name,
      description: event.item.description,
      active: false, // Soft delete
      iconUrl: event.item.iconUrl,
      sortOrder: event.item.sortOrder,
    );

    result.fold(
      (error) => emit(EventTypesListFailure(error)),
      (success) {
        emit(const EventTypeDeleteSuccess("Event type deleted successfully"));
        add(const FetchEventTypes(page: 0, size: 100)); // Reload list
      },
    );
  }
  Future<void> _onGetEventTypeById(
    GetEventTypeByIdEvent event,
    Emitter<EventTypeState> emit,
  ) async {
    emit(EventTypeDetailLoading());

    final result = await getEventTypeByIdUseCase(event.id);

    result.fold(
      (error) => emit(EventTypeDetailFailure(error)),
      (data) => emit(EventTypeDetailLoaded(data)),
    );
  }

  Future<void> _onUpdateEventType(
    UpdateEventType event,
    Emitter<EventTypeState> emit,
  ) async {
    emit(UpdateEventTypeLoading());

    final result = await updateEventTypeUsecase(
      id: event.id,
      name: event.name,
      description: event.description,
      iconUrl: event.iconUrl,
      iconPublicId: event.iconPublicId,
      active: event.active,
      sortOrder: event.sortOrder,
    );

    result.fold(
      (error) => emit(UpdateEventTypeFailure(error)),
      (success) => emit(const UpdateEventTypeSuccess("Event type updated successfully")),
    );
  }
}

