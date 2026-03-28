import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/profile/domain/models/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<String, UserProfile>> getUserProfile();
  Future<Either<String, void>> updateUserProfile({
    required String name,
    required String email,
    required String cityId,
  });
}
