import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/decorations/domain/models/decoration_detail.dart';
import 'package:flutter_online/features/decorations/domain/usecases/delete_decoration_usecase.dart';
import '../../domain/usecases/get_decoration_by_id_usecase.dart';
import '../../domain/models/create_decoration_model.dart';

part 'events/decoration_detail_event.dart';
part 'states/decoration_detail_state.dart';

class DecorationDetailBloc extends Bloc<DecorationDetailEvent, DecorationDetailState> {
  final GetDecorationByIdUseCase getDecorationByIdUseCase;

  DecorationDetailBloc({required this.getDecorationByIdUseCase}) : super(DecorationDetailInitial()) {
    on<LoadDecorationDetail>(_onLoadDetail);
  }

  Future<void> _onLoadDetail(LoadDecorationDetail event, Emitter<DecorationDetailState> emit) async {
    emit(DecorationDetailLoading());

    final result = await getDecorationByIdUseCase(event.id);

    result.fold(
      (error) => emit(DecorationDetailError(error)),
      (data) => emit(DecorationDetailLoaded(data)),
    );
  }
}
