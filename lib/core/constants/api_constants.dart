import 'package:flutter_online/core/config/flavor_config.dart';

class ApiConstants {
  // API Endpoints
  //static const String baseUrl = 'http://127.0.0.1:8080';
  static String get baseUrl => FlavorConfig.instance.baseUrl;

  static const String apiVersion = '/v1';

  // Auth endpoints
  static String get sendOtp => '$baseUrl/auth/send-otp';
  static String get verifyOtp => '$baseUrl/auth/verify-otp';

  // Event endpoints
  static const String events = '/events';
  static const String eventDetail = '/events/{id}';

  // Booking endpoints
  static String get bookings => '$baseUrl/api/bookings';
  static String get myBookings => '$baseUrl/api/bookings/my';
  static String get createBooking => '$baseUrl/api/bookings';

  //Address End Points
  static String get createAddressApi => "$baseUrl/api/addresses";
  static String get getAddressesApi => "$baseUrl/api/addresses/my";
  static String get deleteAddressApi => "$baseUrl/api/addresses/{id}";

  // Event type endpoints
  static String get createEventType => '$baseUrl/api/admin/event-types';
  static String get fetchEventTypes => '$baseUrl/catalog/event-types';
  static String get updateEventType => '$baseUrl/api/admin/event-types/{id}';
  static String get deleteEventType => '$baseUrl/api/admin/event-types/{id}';

  // Decoration endpoints (Admin)
  static String get createDecoration => '$baseUrl/api/admin/decorations';
  static String get updateDecoration => '$baseUrl/api/admin/decorations/{id}';
  static String get deleteDecoration => '$baseUrl/api/admin/decorations/{id}';

  // Catalog upload (Cloudinary via backend) – multipart: file + folder
  static String get catalogUpload => '$baseUrl/catalog/upload';

  // Cities endpoints (Admin - for dropdowns)
  static String get fetchCities => '$baseUrl/catalog/cities';

  // Admin Home (hero, categories, services, featured event, real celebrations, trending decorations)
  static String get adminHome => '$baseUrl/api/admin/home';
  static String get fetchAdminBookings => "$baseUrl/admin/bookings";
  static String get adminBookingDetail => "$baseUrl/admin/bookings/{id}";
  static String get updateBookingStatus =>
      "$baseUrl/admin/bookings/{id}/status";
  static String get cancelBooking => "$baseUrl/admin/bookings/{id}/cancel";
  static String get updateBookingDetail => "$baseUrl/api/bookings/update/{id}";
  static String get adminVendors => '$baseUrl/admin/vendors';
  static String get vendorAssignments => '$baseUrl/admin/vendors/assignments';
  static String get assignVendors =>
      "$baseUrl/admin/bookings/{id}/assign-vendors";
  static String get deAssignVendor =>
      "$baseUrl/admin/bookings/{id}/vendors/{vendorId}";
  static String get adminDashboard => "$baseUrl/admin/dashboard";

  // Public events (user-side, no auth required)
  static String get publicEvents => '$baseUrl/api/public/events';

  // Public decorations (user-side)
  static String get publicDecorations => '$baseUrl/api/public/decorations';
  static String get publicDecorationDetail =>
      '$baseUrl/api/public/decorations/{id}';

  // Payment endpoints (backend: POST /api/payments/create-order with body { bookingId, amount })
  static String get createOrder => '$baseUrl/api/payments/create-order';
  static String get paymentWebhook => '$baseUrl/api/payments/webhook';

  // Vendor endpoints
  static String get vendorBookings => '$baseUrl/vendor/bookings';
  static String get vendorPendingBookings => '$baseUrl/vendor/bookings/pending';
  static String get vendorAcceptedBookings =>
      '$baseUrl/vendor/bookings/accepted';
  static String get vendorCompletedBookings =>
      '$baseUrl/vendor/bookings/completed';
  static String get vendorAcceptBooking =>
      '$baseUrl/vendor/bookings/{id}/accept';
  static String get vendorCompleteBooking =>
      '$baseUrl/vendor/bookings/{id}/complete';
  static String get vendorBookingDetail => '$baseUrl/vendor/bookings/{id}';

  // Add more API constants here

  static const String token = 'auth_token';

  static String get userProfile => "$baseUrl/api/user/profile";
}
