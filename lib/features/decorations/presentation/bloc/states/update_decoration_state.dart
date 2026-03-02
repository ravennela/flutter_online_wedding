import 'package:equatable/equatable.dart';

abstract class UpdateDecorationState extends Equatable {
  const UpdateDecorationState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class UpdateDecorationInitial extends UpdateDecorationState {}

/// Submitting update decoration.
class UpdateDecorationSubmitting extends UpdateDecorationState {}

/// Update decoration success.
class UpdateDecorationSuccess extends UpdateDecorationState {
  final String message;

  const UpdateDecorationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Update decoration failure.
class UpdateDecorationFailure extends UpdateDecorationState {
  final String error;

  const UpdateDecorationFailure(this.error);

  @override
  List<Object?> get props => [error];
}
