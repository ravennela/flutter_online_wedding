
import 'package:dartz/dartz.dart';
import 'package:flutter_online/core/errors/failures.dart';
import 'package:flutter_online/features/auth/domain/models/verify_otp_model.dart';
import 'package:flutter_online/features/auth/domain/repository/auth_repository.dart';

class VerifyOtpUsecase {
 final AuthRepository repository;
  VerifyOtpUsecase(this.repository);
  Future<Either<Failure, VerifyOtpModel>> call(String phone, String otp) {
    return repository.verifyOtp(phone, otp);
  }
}