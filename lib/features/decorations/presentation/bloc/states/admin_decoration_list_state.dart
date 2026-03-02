part of '../admin_decoration_list_bloc.dart';

abstract class AdminDecorationListState {}

class AdminDecorationListInitial extends AdminDecorationListState {}

class AdminDecorationListLoading extends AdminDecorationListState {}

class AdminDecorationListLoaded extends AdminDecorationListState {
  final DecorationListResponse response;
  AdminDecorationListLoaded(this.response);
}

class AdminDecorationListError extends AdminDecorationListState {
  final String message;
  AdminDecorationListError(this.message);
}

class AdminDecorationDeleteSuccess extends AdminDecorationListState {
  final String message;
  AdminDecorationDeleteSuccess(this.message);
}
