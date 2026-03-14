import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/home/domain/usecases/get_admin_home_usecase.dart';
import 'package:flutter_online/features/home/presentation/bloc/admin_home_event.dart';
import 'package:flutter_online/features/home/presentation/bloc/admin_home_state.dart';

class AdminHomeBloc extends Bloc<AdminHomeEvent, AdminHomeState> {
  final GetAdminHomeUsecase getAdminHomeUsecase;

  AdminHomeBloc({required this.getAdminHomeUsecase})
    : super(const AdminHomeInitial()) {
    on<FetchAdminHome>(_onFetchAdminHome);
  }

  Future<void> _onFetchAdminHome(
    FetchAdminHome event,
    Emitter<AdminHomeState> emit,
  ) async {
    emit(const AdminHomeLoading());

    final result = await getAdminHomeUsecase();

    result.fold(
      (error) => emit(AdminHomeFailure(error)),
      (data) => emit(AdminHomeLoaded(data)),
    );
  }
}
