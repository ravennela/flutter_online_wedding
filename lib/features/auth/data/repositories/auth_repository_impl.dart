import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_online/features/auth/domain/models/send_otp_model.dart';
import 'package:flutter_online/features/auth/domain/models/verify_otp_model.dart';
import 'package:flutter_online/features/auth/domain/repository/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../sources/auth_remote_source.dart';
import '../../domain/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource remoteSource;

  AuthRepositoryImpl(this.remoteSource);

  String _mapExceptionToMessage(dynamic e) {
    if (e is SocketException) return 'No internet connection';
    if (e is ServerException) return e.message;
    if (e is UnauthorizedException) return e.message;
    if (e is DioException) {
      return e.response?.data?['message']?.toString() ??
          e.message ??
          'Connection error';
    }
    return e.toString();
  }

  @override
  Future<Either<String, SendOtpModel>> login(String phone) async {
    try {
      final response = await remoteSource.login(phone);
      return Right(SendOtpModel.fromJson(response));
    } catch (e) {
      return Left(_mapExceptionToMessage(e));
    }
  }

  @override
  Future<Either<Failure, VerifyOtpModel>> verifyOtp(String phone, String otp) async {
    try {
      final user = await remoteSource.verifyOtp(phone, otp);
      return Right(VerifyOtpModel.fromJson(user));
    } catch (e) {
      return Left(ServerFailure(_mapExceptionToMessage(e)));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_mapExceptionToMessage(e)));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final user = await remoteSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(_mapExceptionToMessage(e)));
    }
  }
}
