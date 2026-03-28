import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/profile/domain/repository/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<Either<String, void>> call({
    required String name,
    required String email,
    required String cityId,
  }) {
    return repository.updateUserProfile(
      name: name,
      email: email,
      cityId: cityId,
    );
  }
}
