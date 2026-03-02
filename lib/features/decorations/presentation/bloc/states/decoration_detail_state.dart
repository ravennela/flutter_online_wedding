part of '../decoration_detail_bloc.dart';

abstract class DecorationDetailState {}

class DecorationDetailInitial extends DecorationDetailState {}

class DecorationDetailLoading extends DecorationDetailState {}

class DecorationDetailLoaded extends DecorationDetailState {
  final DecorationDetail detail;
  DecorationDetailLoaded(this.detail);
}

class DecorationDetailError extends DecorationDetailState {
  final String message;
  DecorationDetailError(this.message);
}
