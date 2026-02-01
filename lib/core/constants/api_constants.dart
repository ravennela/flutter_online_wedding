class ApiConstants {
  // API Endpoints
  static const String baseUrl = 'http://127.0.0.1:8080';
  static const String apiVersion = '/v1';
  
  // Auth endpoints
  static const String sendOtp = '$baseUrl/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';

  
  // Event endpoints
  static const String events = '/events';
  static const String eventDetail = '/events/{id}';
  
  // Booking endpoints
  static const String bookings = '/bookings';
  static const String createBooking = '/bookings';

  // Event type endpoints
  static const String createEventType = '$baseUrl/api/admin/event-types';
  static const String fetchEventTypes = '$baseUrl/api/admin/event-types';

  // Decoration endpoints (Admin)
  static const String createDecoration = '$baseUrl/api/admin/decorations';

  // Cities endpoints (Admin - for dropdowns)
  static const String fetchCities = '$baseUrl/api/admin/cities';

  // Add more API constants here

  static const String token = 'auth_token';
}
