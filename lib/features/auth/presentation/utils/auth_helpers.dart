import 'package:flutter/material.dart';
import 'package:flutter_online/features/auth/domain/models/login_redirect_data.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';

/// Handles post-login navigation based on redirect data.
/// When pending redirect exists (e.g. /booking/:id), GoRouter redirect handles it;
/// we avoid context.go() from BlocListener to prevent didPopNext after dispose().
void onLoginSuccess(
  BuildContext context,
  LoginRedirectData? redirectData, {
  String? userRole,
}) {
  final effectiveRedirect = redirectData ?? LoginRedirectData.pending;
  // When a redirect is pending (e.g. to /booking/:id), do NOT navigate here.
  // GoRouter's redirect() consumes LoginRedirectData.pending and returns the path,
  // so navigation happens in the router and never triggers didPopNext on a disposed route.
  if (effectiveRedirect != null) return;

  LoginRedirectData.pending = null;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    final isAdmin = (userRole ?? '').toUpperCase() == 'ADMIN';
    if (isAdmin) {
      context.go(AppRoutes.adminDashboard);
    } else {
      context.go('/');
    }
  });
}
