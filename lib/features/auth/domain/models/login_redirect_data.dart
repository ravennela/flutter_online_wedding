/// Represents the action to resume after successful login.
/// Used when user attempts a protected action (e.g. Book Now) while not logged in.
class LoginRedirectData {
  final String nextRoute;
  final Object? extra;

  const LoginRedirectData({
    required this.nextRoute,
    this.extra,
  });

  /// Pending redirect stored globally so it survives GoRouter refresh cycles
  /// (GoRouter's `extra` is transient and lost on refreshListenable refresh).
  /// Set when user triggers a protected action while logged out.
  /// Consumed (and cleared) after successful login.
  static LoginRedirectData? pending;
}
