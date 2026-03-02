part of '../admin_decoration_list_bloc.dart';

abstract class AdminDecorationListEvent {}

class LoadAdminDecorations extends AdminDecorationListEvent {
  final int page;
  final int size;
  final String? search;
  final String? cityId;
  final String? eventTypeId;
  final bool? active;
  final String? sortBy;
  final String? sortDir;

  LoadAdminDecorations({
    this.page = 0,
    this.size = 10,
    this.search,
    this.cityId,
    this.eventTypeId,
    this.active,
    this.sortBy,
    this.sortDir,
  });
}

class DeleteAdminDecoration extends AdminDecorationListEvent {
  final String id;
  DeleteAdminDecoration(this.id);
}
