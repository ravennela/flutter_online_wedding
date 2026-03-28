import 'package:dartz/dartz.dart';
import 'package:flutter_online/core/errors/exceptions.dart';
import 'package:flutter_online/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:flutter_online/features/profile/domain/models/user_profile.dart';
import 'package:flutter_online/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, UserProfile>> getUserProfile() async {
    try {
      final profile = await remoteDataSource.getUserProfile();
      return Right(profile);
    } on AppException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateUserProfile({
    required String name,
    required String email,
    required String cityId,
  }) async {
    try {
      await remoteDataSource.updateUserProfile(
        name: name,
        email: email,
        cityId: cityId,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
