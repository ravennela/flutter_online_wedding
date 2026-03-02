import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/booking_model.dart';
import '../models/booking_page_result.dart';
import '../models/booking_detail_model.dart';

abstract class BookingRemoteSource {
  Future<BookingPageResult> getMyBookingsPage(int page, int size);
  Future<BookingDetailModel> getBookingById(String bookingId);
  Future<void> cancelBooking(String bookingId);
  Future<BookingModel> createBooking(
    String eventId,
    Map<String, dynamic> bookingData,
  );
  Future<BookingModel> confirmBooking(String bookingId);
}

class BookingRemoteSourceImpl implements BookingRemoteSource {
  final ApiClient apiClient;

  BookingRemoteSourceImpl(this.apiClient);

  @override
  Future<BookingPageResult> getMyBookingsPage(int page, int size) async {
    try {
      final response = await apiClient.get(
        ApiConstants.myBookings,
        queryParameters: {'page': page, 'size': size},
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerException('Invalid response format');
      }
      return BookingPageResult.fromJson(data);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load bookings: ${e.toString()}');
    }
  }

  @override
  Future<BookingDetailModel> getBookingById(String bookingId) async {
    try {
      final path = '${ApiConstants.bookings}/$bookingId';
      final response = await apiClient.get(path);
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerException('Invalid response format');
      }
      return BookingDetailModel.fromJson(data);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load booking details: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    if (bookingId.isEmpty) {
      throw ServerException('Invalid booking ID');
    }
    try {
      final path = '${ApiConstants.bookings}/$bookingId/cancel';
      await apiClient.patch(path);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to cancel booking: ${e.toString()}');
    }
  }

  @override
  Future<BookingModel> createBooking(
    String eventId,
    Map<String, dynamic> bookingData,
  ) async {
    try {
        final requestBody = {'eventTypeId': eventId, ...bookingData};

      print("Booking Request: $requestBody");
      final response = await apiClient.post(
        ApiConstants.createBooking,
        data: {'eventTypeId': eventId, ...bookingData},
      );
    

      final data = response.data;
      final Map<String, dynamic> bookingJson =
          data is Map<String, dynamic> && data['booking'] != null
          ? data['booking'] as Map<String, dynamic>
          : data as Map<String, dynamic>;

      return BookingModel.fromJson(bookingJson);
    } catch (e) {
      throw ServerException('Failed to create booking: ${e.toString()}');
    }
  }

  @override
  Future<BookingModel> confirmBooking(String bookingId) async {
    try {
      final response = await apiClient.post(
        '${ApiConstants.bookings}/$bookingId/confirm',
      );
      return BookingModel.fromJson(
        response.data['booking'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw ServerException('Failed to confirm booking: ${e.toString()}');
    }
  }
}
