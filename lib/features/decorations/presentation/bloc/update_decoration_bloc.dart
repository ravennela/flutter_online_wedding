import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/decorations/domain/usecases/update_decoration_usecase.dart';
import 'events/update_decoration_event.dart';
import 'states/update_decoration_state.dart';

class UpdateDecorationBloc
    extends Bloc<UpdateDecorationEvent, UpdateDecorationState> {
  final UpdateDecorationUseCase updateDecorationUseCase;

  UpdateDecorationBloc({
    required this.updateDecorationUseCase,
  }) : super(UpdateDecorationInitial()) {
    on<SubmitUpdateDecoration>(_onSubmitUpdateDecoration);
  }

  Future<void> _onSubmitUpdateDecoration(
    SubmitUpdateDecoration event,
    Emitter<UpdateDecorationState> emit,
  ) async {
    emit(UpdateDecorationSubmitting());

    final result = await updateDecorationUseCase(
      id: event.id,
      eventTypeId: event.eventTypeId,
      cityId: event.cityId,
      name: event.name,
      description: event.description,
      inclusions: event.inclusions,
      exclusions: event.exclusions,
      basePrice: event.basePrice,
      active: event.active,
    );

    result.fold(
      (error) => emit(UpdateDecorationFailure(error)),
      (model) => emit(UpdateDecorationSuccess(model.name)),
    );
  }
}
