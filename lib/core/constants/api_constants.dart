class ApiConstants {
  // API Endpoints
  static const String baseUrl = 'http://127.0.0.1:8080';
  static const String apiVersion = '/v1';
  
  // Auth endpoints
  static const String sendOtp = '$baseUrl/auth/send-otp';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';

  
  // Event endpoints
  static const String events = '/events';
  static const String eventDetail = '/events/{id}';
  
  // Booking endpoints
  static const String bookings = '$baseUrl/api/bookings';
  static const String myBookings = '$baseUrl/api/bookings/my';
  static const String createBooking = '$baseUrl/api/bookings';


  //Address End Points
  static const String createAddressApi="$baseUrl/api/addresses";
  static const String getAddressesApi="$baseUrl/api/addresses/my";
  static const String deleteAddressApi="$baseUrl/api/addresses/{id}";

  // Event type endpoints
  static const String createEventType = '$baseUrl/api/admin/event-types';
  static const String fetchEventTypes = '$baseUrl/catalog/event-types';
  static const String updateEventType = '$baseUrl/api/admin/event-types/{id}';
  static const String deleteEventType = '$baseUrl/api/admin/event-types/{id}';
  

  // Decoration endpoints (Admin)
  static const String createDecoration = '$baseUrl/api/admin/decorations';
  static const String updateDecoration = '$baseUrl/api/admin/decorations/{id}';
  static const String deleteDecoration = '$baseUrl/api/admin/decorations/{id}';

  // Cities endpoints (Admin - for dropdowns)
  static const String fetchCities = '$baseUrl/catalog/cities';

  // Admin Home (hero, categories, services, featured event, real celebrations, trending decorations)
  static const String adminHome = '$baseUrl/api/admin/home';
   static const String fetchAdminBookings="$baseUrl/admin/bookings";
   static const String adminBookingDetail = "$baseUrl/admin/bookings/{id}";
   static const String updateBookingStatus = "$baseUrl/admin/bookings/{id}/status";
   static const String cancelBooking = "$baseUrl/admin/bookings/{id}/cancel";
   static const String adminVendors = '$baseUrl/admin/vendors';
   static const String vendorAssignments = '$baseUrl/admin/vendors/assignments';
   static const String assignVendors = "$baseUrl/admin/bookings/{id}/assign-vendors";
   static const String deAssignVendor = "$baseUrl/admin/bookings/{id}/vendors/{vendorId}";



  // Public events (user-side, no auth required)
  static const String publicEvents = '$baseUrl/api/public/events';

  // Public decorations (user-side)
  static const String publicDecorations = '$baseUrl/api/public/decorations';
  static const String publicDecorationDetail = '$baseUrl/api/public/decorations/{id}';

  // Payment endpoints (backend: POST /api/payments/create-order with body { bookingId, amount })
  static const String createOrder = '$baseUrl/api/payments/create-order';
  static const String paymentWebhook = '$baseUrl/api/payments/webhook';

  // Vendor endpoints
  static const String vendorBookings = '$baseUrl/vendor/bookings';
  static const String vendorPendingBookings = '$baseUrl/vendor/bookings/pending';
  static const String vendorAcceptedBookings = '$baseUrl/vendor/bookings/accepted';
  static const String vendorCompletedBookings = '$baseUrl/vendor/bookings/completed';
  static const String vendorAcceptBooking = '$baseUrl/vendor/bookings/{id}/accept';
  static const String vendorCompleteBooking = '$baseUrl/vendor/bookings/{id}/complete';
  static const String vendorBookingDetail = '$baseUrl/vendor/bookings/{id}';

  // Add more API constants here

  static const String token = 'auth_token';
}
