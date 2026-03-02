import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/decorations/domain/models/decoration_list_response.dart';
import 'package:flutter_online/features/decorations/domain/usecases/delete_decoration_usecase.dart';
import 'package:flutter_online/features/decorations/domain/usecases/get_decorations_usecase.dart';

part 'events/admin_decoration_list_event.dart';
part 'states/admin_decoration_list_state.dart';

class AdminDecorationListBloc extends Bloc<AdminDecorationListEvent, AdminDecorationListState> {
  final GetDecorationsUseCase getDecorationsUseCase;
  final DeleteDecoration deleteDecorationUseCase;

  AdminDecorationListBloc({
    required this.getDecorationsUseCase,
    required this.deleteDecorationUseCase,
  }) : super(AdminDecorationListInitial()) {
    on<LoadAdminDecorations>(_onLoadDecorations);
    on<DeleteAdminDecoration>(_onDeleteDecoration);
  }

  Future<void> _onLoadDecorations(LoadAdminDecorations event, Emitter<AdminDecorationListState> emit) async {
    emit(AdminDecorationListLoading());
    final result = await getDecorationsUseCase(
      page: event.page,
      size: event.size,
      search: event.search,
      cityId: event.cityId,
      eventTypeId: event.eventTypeId,
      active: event.active,
      sortBy: event.sortBy,
      sortDir: event.sortDir,
    );
    result.fold(
      (failure) => emit(AdminDecorationListError(failure)),
      (response) => emit(AdminDecorationListLoaded(response)),
    );
  }

  Future<void> _onDeleteDecoration(DeleteAdminDecoration event, Emitter<AdminDecorationListState> emit) async {
    // We might want to show a loading state specifically for deletion, but usually we just show a snackbar or overlay. 
    // If we emit Loading, it might replace the list. Ideally we keep the list and show loading overlay.
    // For now, let's assume the UI handles overlay or we emit a state that preserves the list?
    // Typical pattern: Emit Loading (could clear list), or ideally have a separate DeleteStatus or consumeListener.
    // Simplified: Emit Loading -> Success/Error.
    
    // NOTE: To avoid clearing simple list, we usually handle this with a 'Action' stream or separate state property,
    // but for simplicity here we will just emit Loading and then reload or success.
    
    // Ideally we shouldn't replace the 'List' state with 'DeleteSuccess' if we want to show the list. 
    // However, after delete, we usually want to reload.
    emit(AdminDecorationListLoading());
    
    final result = await deleteDecorationUseCase(event.id);
    
    result.fold(
      (failure) => emit(AdminDecorationListError(failure.message)), // Assuming Failure has message, or toString
      (_) {
        emit(AdminDecorationDeleteSuccess("Decoration deleted successfully"));
        add(LoadAdminDecorations()); // Reload list
      },
    );
  }
}
