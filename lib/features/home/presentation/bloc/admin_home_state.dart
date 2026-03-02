import 'package:equatable/equatable.dart';
import 'package:flutter_online/features/home/domain/models/admin_home_model.dart';

abstract class AdminHomeState extends Equatable {
  const AdminHomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminHomeInitial extends AdminHomeState {
  const AdminHomeInitial();
}

/// Loading while fetching admin home
class AdminHomeLoading extends AdminHomeState {
  const AdminHomeLoading();
}

/// Success with admin home data
class AdminHomeLoaded extends AdminHomeState {
  final AdminHomeModel data;

  const AdminHomeLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// Error state
class AdminHomeFailure extends AdminHomeState {
  final String message;

  const AdminHomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
