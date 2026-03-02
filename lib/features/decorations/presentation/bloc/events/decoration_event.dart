part of '../decoration_bloc.dart';

abstract class DecorationEvent {}

class LoadDecorations extends DecorationEvent {
  final String? eventId;
  LoadDecorations({this.eventId});
}
