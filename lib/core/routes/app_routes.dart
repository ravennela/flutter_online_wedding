class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String eventList = '/events';
  static const String eventDetail = '/events/detail';
  static const String decorationDetail = '/decoration/detail';
  static const String myBookings = '/bookings';
  static const String bookingConfirm = '/bookings/confirm';
  static const String profile = '/profile';
  static const String adminDashboard = '/admin';
  
  // Route paths with parameters
  static String eventDetailPath(String id) => '/events/detail/$id';
  static String decorationDetailPath(String id) => '/decoration/detail/$id';
}
