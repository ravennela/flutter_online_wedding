import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';
import 'admin_dashboard_event_state.dart';

class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final GetAdminDashboardDataUseCase getAdminDashboardDataUseCase;

  AdminDashboardBloc({required this.getAdminDashboardDataUseCase})
      : super(AdminDashboardInitial()) {
    on<FetchAdminDashboardData>(_onFetchAdminDashboardData);
  }

  Future<void> _onFetchAdminDashboardData(
    FetchAdminDashboardData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(AdminDashboardLoading());
    final result = await getAdminDashboardDataUseCase();
    result.fold(
      (error) => emit(AdminDashboardError(message: error)),
      (data) => emit(AdminDashboardLoaded(dashboardData: data)),
    );
  }
}
