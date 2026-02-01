import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/decorations/domain/usecases/get_decorations_usecase.dart';
import 'package:flutter_online/features/decorations/presentation/bloc/admin_decoration_list_state.dart';

class AdminDecorationListCubit extends Cubit<AdminDecorationListState> {
  final GetDecorationsUseCase getDecorationsUseCase;

  AdminDecorationListCubit(this.getDecorationsUseCase) : super(AdminDecorationListInitial());

  Future<void> loadDecorations({
    int page = 0,
    int size = 10,
    String? search,
    String? cityId,
    String? eventTypeId,
    bool? active,
    String? sortBy,
    String? sortDir,
  }) async {
    emit(AdminDecorationListLoading());
    final result = await getDecorationsUseCase(
      page: page,
      size: size,
      search: search,
      cityId: cityId,
      eventTypeId: eventTypeId,
      active: active,
      sortBy: sortBy,
      sortDir: sortDir,
    );
    result.fold(
      (failure) => emit(AdminDecorationListError(failure)),
      (response) => emit(AdminDecorationListLoaded(response)),
    );
  }
}
