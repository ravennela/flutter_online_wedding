import 'package:equatable/equatable.dart';
import 'package:flutter_online/features/decorations/domain/models/decoration_image_payload.dart';

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
/// [images] = list of { url, publicId } from Cloudinary upload for decoration_images.
class SubmitCreateDecoration extends CreateDecorationEvent {
  final String eventTypeId;
  final String cityId;
  final String name;
  final String? description;
  final String? inclusions;
  final String? exclusions;
  final int basePrice;
  final List<DecorationImagePayload> images;
  final bool active;

  const SubmitCreateDecoration({
    required this.eventTypeId,
    required this.cityId,
    required this.name,
    this.description,
    this.inclusions,
    this.exclusions,
    required this.basePrice,
    this.images = const [],
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
        images,
        active,
      ];
}
