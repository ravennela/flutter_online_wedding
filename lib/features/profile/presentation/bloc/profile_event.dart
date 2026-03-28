abstract class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String email;
  final String cityId;

  UpdateProfileEvent({
    required this.name,
    required this.email,
    required this.cityId,
  });
}
