part of '../decoration_bloc.dart';

abstract class DecorationState {}

class DecorationInitial extends DecorationState {}

class DecorationLoading extends DecorationState {}

class DecorationLoaded extends DecorationState {
  final List<DecorationItem> decorations;
  DecorationLoaded(this.decorations);
}

class DecorationError extends DecorationState {
  final String message;
  DecorationError(this.message);
}
