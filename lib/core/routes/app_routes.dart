class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String citySelection = '/city-selection';
  static const String login = '/login';
  static const String otp = '/verify-otp';
  static const String home = '/';
  static const String eventList = '/events';
  static const String eventDetail = '/events/detail';
  static const String decorationDetail = '/decoration/detail';
  static const String myBookings = '/bookings';
  static const String bookingDetail = '/bookings/detail';
  static const String bookingConfirm = '/bookings/confirm';
  static const String booking = '/booking';
  static const String profile = '/profile';
  static const String adminDashboard = '/admin';
   static const String adminBookings = '/admin/bookings';
   static const String adminBookingDetail = '/admin/bookings/details';
   static const String adminEditBooking = '/admin/bookings/edit';
   static const String adminEventTypes = '/admin/event-types';
   static const String adminVendors = '/admin/vendors';


  static const String adminEventTypesCreate = '/admin/event-types/create';
  static const String adminDecorations = '/admin/decorations';
  static const String adminDecorationsCreate = '/admin/decorations/create';
  static const String adminEventTypesDetail = '/admin/event_types_detail'; // using distinct path to avoid confusion or nested

  static const String adminEventTypesEdit = '/admin/event-types/edit';
  static const String adminDecorationsDetail = '/admin/decorations/detail';
  static const String editDeceoration = '/admin/decorations/edit';
  static const String addAddress = '/address/add';
  static const String addressList = '/address/list';
  static const String selectEventDate = '/booking/:id/select-date';
  static const String paymentMethod = '/booking/:id/payment';
  static const String bookingSuccess = '/booking/success';
  static const String adminSelectVendor = '/admin/bookings/select-vendor';


  // Route paths with parameters
  static String eventDetailPath(String id) => '/events/detail/$id';
  static String decorationDetailPath(String id) => '/decoration/detail/$id';
  static String adminEventTypesDetailPath(String id) => '/admin/event_types_detail/$id';
  static String adminEventTypesEditPath(String id) => '/admin/event-types/edit/$id';
  static String adminDecorationsDetailPath(String id) => '/admin/decorations/detail/$id';
  static String editDeceorationPath(String id) => '/admin/decorations/edit/$id';
  static String bookingDetailPath(String id) => '$bookingDetail/$id';
}
