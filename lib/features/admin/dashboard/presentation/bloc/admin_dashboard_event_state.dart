import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_dashboard_entity.dart';

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchAdminDashboardData extends AdminDashboardEvent {}

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final AdminDashboardEntity dashboardData;

  const AdminDashboardLoaded({required this.dashboardData});

  @override
  List<Object?> get props => [dashboardData];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
