import 'package:equatable/equatable.dart';
import 'package:flutter_online/features/auth/domain/models/verify_otp_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final VerifyOtpModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted when OTP is sent successfully; UI should navigate to OTP screen.
class OtpSent extends AuthState {
  final String phone;

  const OtpSent(this.phone);

  @override
  List<Object?> get props => [phone];
}
