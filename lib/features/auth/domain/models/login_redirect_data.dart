/// Represents the action to resume after successful login.
/// Used when user attempts a protected action (e.g. Book Now) while not logged in.
class LoginRedirectData {
  final String nextRoute;
  final Object? extra;

  const LoginRedirectData({
    required this.nextRoute,
    this.extra,
  });
}
