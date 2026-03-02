import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/auth/domain/usecase/send_otp_usecase.dart';
import 'package:flutter_online/features/auth/domain/usecase/verify_otp_usecase.dart';
import 'package:flutter_online/features/auth/presentation/widgets/auth_data_storage.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../data/repositories/auth_repository_impl.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUsecase authRepository;
  final VerifyOtpUsecase verifyOtpUsecase;
  final AuthLocalDataSource authLocalDataSource;

  AuthBloc(this.authRepository, this.verifyOtpUsecase, this.authLocalDataSource)
    : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.call(event.phone);
      result.fold(
        (failure) => emit(AuthError(failure.toString())),
        (success) => emit(OtpSent(event.phone)),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(
  VerifyOtpRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());

  try {
    final result = await verifyOtpUsecase.call(event.phone, event.otp);

    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (user) async {
        await authLocalDataSource.saveToken(user.token);
        await authLocalDataSource.saveUser(user);

        if (!emit.isDone) {
          emit(AuthAuthenticated(user));
        }
      },
    );
  } catch (e) {
    if (!emit.isDone) {
      emit(AuthError(e.toString()));
    }
  }
}

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authLocalDataSource.clearAll();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final token = await authLocalDataSource.getToken();
      final user = await authLocalDataSource.getUser();

      if (token != null && user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
