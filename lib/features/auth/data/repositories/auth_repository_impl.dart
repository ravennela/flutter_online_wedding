import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/auth/domain/models/send_otp_model.dart';
import 'package:flutter_online/features/auth/domain/repository/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../sources/auth_remote_source.dart';
import '../../domain/models/user_model.dart';



class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource remoteSource;
  
  AuthRepositoryImpl(this.remoteSource);
  
  @override
  Future<Either<String, SendOtpModel>> login(String phone) async {
    try {
      final response= await remoteSource.login(phone);
      return  Right(SendOtpModel.fromJson(response));
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
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
