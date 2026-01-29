import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../sources/auth_remote_source.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> login(String phone);
  Future<Either<Failure, UserModel>> verifyOtp(String phone, String otp);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserModel>> getCurrentUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource remoteSource;
  
  AuthRepositoryImpl(this.remoteSource);
  
  @override
  Future<Either<Failure, void>> login(String phone) async {
    try {
      await remoteSource.login(phone);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, UserModel>> verifyOtp(String phone, String otp) async {
    try {
      final user = await remoteSource.verifyOtp(phone, otp);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final user = await remoteSource.getCurrentUser();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
