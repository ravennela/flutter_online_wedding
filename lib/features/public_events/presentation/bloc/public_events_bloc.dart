import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/public_events/domain/usecases/get_public_events_usecase.dart';
import 'package:flutter_online/features/public_events/presentation/bloc/public_events_event.dart';
import 'package:flutter_online/features/public_events/presentation/bloc/public_events_state.dart';

class PublicEventsBloc extends Bloc<PublicEventsEvent, PublicEventsState> {
  final GetPublicEventsUsecase getPublicEventsUsecase;

  PublicEventsBloc({
    required this.getPublicEventsUsecase,
  }) : super(const PublicEventsInitial()) {
    on<FetchPublicEvents>(_onFetchPublicEvents);
  }

  Future<void> _onFetchPublicEvents(
    FetchPublicEvents event,
    Emitter<PublicEventsState> emit,
  ) async {
    emit(const PublicEventsLoading());

    final result = await getPublicEventsUsecase();

    result.fold(
      (error) => emit(PublicEventsFailure(error)),
      (events) => emit(PublicEventsLoaded(events)),
    );
  }
}
