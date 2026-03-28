import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/profile/domain/models/user_profile.dart';
import 'package:flutter_online/features/profile/domain/repository/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase({required this.repository});

  Future<Either<String, UserProfile>> call() {
    return repository.getUserProfile();
  }
}
