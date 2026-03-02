import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/decorations/domain/usecases/create_decoration_usecase.dart';
import 'package:flutter_online/features/decorations/domain/usecases/fetch_cities_usecase.dart';
import 'package:flutter_online/features/events/domain/usecases/fetch_event_types_usecase.dart';
import 'events/create_decoration_event.dart';
import 'states/create_decoration_state.dart';

class CreateDecorationBloc
    extends Bloc<CreateDecorationEvent, CreateDecorationState> {
  final CreateDecorationUsecase createDecorationUsecase;
  final FetchCitiesUsecase fetchCitiesUsecase;
  final FetchEventTypesUsecase fetchEventTypesUsecase;

  CreateDecorationBloc({
    required this.createDecorationUsecase,
    required this.fetchCitiesUsecase,
    required this.fetchEventTypesUsecase,
  }) : super(CreateDecorationInitial()) {
    on<LoadEventTypesAndCities>(_onLoadEventTypesAndCities);
    on<SubmitCreateDecoration>(_onSubmitCreateDecoration);
  }

  Future<void> _onLoadEventTypesAndCities(
    LoadEventTypesAndCities event,
    Emitter<CreateDecorationState> emit,
  ) async {
    emit(CreateDecorationLoading());

    final eventTypesResult = await fetchEventTypesUsecase(
      page: 0,
      size: 100,
      search: null,
      active: true,
    );

    final citiesResult = await fetchCitiesUsecase();

    eventTypesResult.fold(
      (error) => emit(CreateDecorationLoadFailure(error)),
      (eventTypesResponse) {
        citiesResult.fold(
          (error) => emit(CreateDecorationLoadFailure(error)),
          (cities) => emit(CreateDecorationFormReady(
            eventTypes: eventTypesResponse.content,
            cities: cities,
          )),
        );
      },
    );
  }

  Future<void> _onSubmitCreateDecoration(
    SubmitCreateDecoration event,
    Emitter<CreateDecorationState> emit,
  ) async {
    emit(CreateDecorationSubmitting());

    final result = await createDecorationUsecase(
      eventTypeId: event.eventTypeId,
      cityId: event.cityId,
      name: event.name,
      description: event.description,
      inclusions: event.inclusions,
      exclusions: event.exclusions,
      basePrice: event.basePrice,
      imageUrls: event.imageUrls,
      active: event.active,
    );

    result.fold(
      (error) => emit(CreateDecorationSubmitFailure(error)),
      (model) => emit(CreateDecorationSubmitSuccess(model.name)),
    );
  }
}
