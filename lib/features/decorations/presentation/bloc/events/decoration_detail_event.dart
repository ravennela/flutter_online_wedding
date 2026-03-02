part of '../decoration_detail_bloc.dart';

abstract class DecorationDetailEvent {}

class LoadDecorationDetail extends DecorationDetailEvent {
  final String id;
  LoadDecorationDetail(this.id);
}
