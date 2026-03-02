import 'package:equatable/equatable.dart';

abstract class UpdateDecorationEvent extends Equatable {
  const UpdateDecorationEvent();

  @override
  List<Object?> get props => [];
}

/// Submit update decoration form.
class SubmitUpdateDecoration extends UpdateDecorationEvent {
  final String id;
  final String eventTypeId;
  final String cityId;
  final String name;
  final String? description;
  final String? inclusions;
  final String? exclusions;
  final int basePrice;
  final bool active;

  const SubmitUpdateDecoration({
    required this.id,
    required this.eventTypeId,
    required this.cityId,
    required this.name,
    this.description,
    this.inclusions,
    this.exclusions,
    required this.basePrice,
    this.active = true,
  });

  @override
  List<Object?> get props => [
        id,
        eventTypeId,
        cityId,
        name,
        description,
        inclusions,
        exclusions,
        basePrice,
        active,
      ];
}
