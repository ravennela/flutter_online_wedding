import 'package:equatable/equatable.dart';

abstract class CreateDecorationEvent extends Equatable {
  const CreateDecorationEvent();

  @override
  List<Object?> get props => [];
}

/// Load event types and cities for dropdowns.
class LoadEventTypesAndCities extends CreateDecorationEvent {
  const LoadEventTypesAndCities();
}

/// Submit create decoration form.
class SubmitCreateDecoration extends CreateDecorationEvent {
  final String eventTypeId;
  final String cityId;
  final String name;
  final String? description;
  final String? inclusions;
  final String? exclusions;
  final int basePrice;
  final List<String> imageUrls;
  final bool active;

  const SubmitCreateDecoration({
    required this.eventTypeId,
    required this.cityId,
    required this.name,
    this.description,
    this.inclusions,
    this.exclusions,
    required this.basePrice,
    this.imageUrls = const [],
    this.active = true,
  });

  @override
  List<Object?> get props => [
        eventTypeId,
        cityId,
        name,
        description,
        inclusions,
        exclusions,
        basePrice,
        imageUrls,
        active,
      ];
}
