import 'package:flutter_online/features/auth/domain/models/login_redirect_data.dart';

/// Arguments passed to OTP screen.
class OtpScreenArgs {
  final String phone;
  final LoginRedirectData? redirectData;

  const OtpScreenArgs({
    required this.phone,
    this.redirectData,
  });
}
