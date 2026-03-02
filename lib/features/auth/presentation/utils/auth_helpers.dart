import 'package:flutter/material.dart';
import 'package:flutter_online/features/auth/domain/models/login_redirect_data.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';

/// Handles post-login navigation based on redirect data.
/// Call this after successful login (e.g. from OTP screen).
void onLoginSuccess(
  BuildContext context,
  LoginRedirectData? redirectData, {
  String? userRole,
}) {
  if (redirectData != null) {
    context.go(
      redirectData.nextRoute,
      extra: redirectData.extra,
    );
  } else if (userRole == 'ADMIN') {
    context.go(AppRoutes.adminDashboard);
  } else {
    context.go('/');
  }
}
