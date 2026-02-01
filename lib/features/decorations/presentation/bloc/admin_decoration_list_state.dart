import 'package:flutter_online/features/decorations/domain/models/decoration_list_response.dart';

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
