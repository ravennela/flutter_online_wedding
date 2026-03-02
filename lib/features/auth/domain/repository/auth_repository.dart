
import 'package:dartz/dartz.dart';
import 'package:flutter_online/core/errors/failures.dart';
import 'package:flutter_online/features/auth/domain/models/send_otp_model.dart';
import 'package:flutter_online/features/auth/domain/models/user_model.dart';
import 'package:flutter_online/features/auth/domain/models/verify_otp_model.dart';

abstract class AuthRepository {
  Future<Either<String, SendOtpModel>> login(String phone);
  Future<Either<Failure, VerifyOtpModel>> verifyOtp(String phone, String otp);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserModel>> getCurrentUser();
}