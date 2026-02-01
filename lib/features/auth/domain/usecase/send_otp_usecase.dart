
import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/auth/domain/models/send_otp_model.dart';
import 'package:flutter_online/features/auth/domain/repository/auth_repository.dart';

class SendOtpUsecase {
  final AuthRepository repository;
  SendOtpUsecase({required this.repository});
  Future<Either<String, SendOtpModel>> call(String phone) async {
    return await repository.login(phone);
  } 
}