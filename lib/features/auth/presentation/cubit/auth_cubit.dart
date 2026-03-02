import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/auth/data/datasources/token_storage.dart';
import 'package:flutter_online/features/auth/domain/usecase/send_otp_usecase.dart';
import 'package:flutter_online/features/auth/domain/usecase/verify_otp_usecase.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SendOtpUsecase sendOtpUsecase;
  final VerifyOtpUsecase verifyOtpUsecase;
  final TokenStorage tokenStorage;

  AuthCubit({
    required this.sendOtpUsecase,
    required this.verifyOtpUsecase,
    required this.tokenStorage,
  }) : super(AuthInitial()) {
    // Allow initial state to remain until checkAuthStatus is called
  }

  /// Called at app startup. Loads token from SharedPreferences.
  /// If token exists → AuthAuthenticated, else → AuthUnauthenticated (guest).
  /// Does NOT force login; guest can browse.
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await tokenStorage.getStoredUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  /// Send OTP to phone number.
  Future<void> sendOtp(String phone) async {
    emit(AuthLoading());
    try {
      final result = await sendOtpUsecase.call(phone);
      result.fold(
        (failure) => emit(AuthError(failure.toString())),
        (success) => emit(OtpSent(phone)),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Verify OTP and complete login.
  /// Saves tokens to SharedPreferences on success.
  Future<void> verifyOtp(String phone, String otp) async {
    emit(AuthLoading());
    try {
      final result = await verifyOtpUsecase.call(phone, otp);
      await result.fold(
        (failure) async {
          emit(AuthError(failure.message));
        },
        (user) async {
          await tokenStorage.saveTokens(user);
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Logout: clear tokens and emit unauthenticated.
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await tokenStorage.clearTokens();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Called when API returns 401. Clear token and emit unauthenticated.
  Future<void> onUnauthorized() async {
    await tokenStorage.clearTokens();
    emit(AuthUnauthenticated());
  }

  bool get isAuthenticated => state is AuthAuthenticated;
}
