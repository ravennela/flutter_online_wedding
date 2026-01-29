import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteSource {
  Future<List<BookingModel>> getMyBookings();
  Future<BookingModel> createBooking(String eventId, Map<String, dynamic> bookingData);
  Future<BookingModel> confirmBooking(String bookingId);
}

class BookingRemoteSourceImpl implements BookingRemoteSource {
  final ApiClient apiClient;
  
  BookingRemoteSourceImpl(this.apiClient);
  
  @override
  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await apiClient.get(ApiConstants.bookings);
      final List<dynamic> data = response.data['bookings'] as List<dynamic>;
      return data.map((json) => BookingModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException('Failed to load bookings: ${e.toString()}');
    }
  }
  
  @override
  Future<BookingModel> createBooking(String eventId, Map<String, dynamic> bookingData) async {
    try {
      final response = await apiClient.post(
        ApiConstants.createBooking,
        data: {
          'event_id': eventId,
          ...bookingData,
        },
      );
      return BookingModel.fromJson(response.data['booking'] as Map<String, dynamic>);
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
      return BookingModel.fromJson(response.data['booking'] as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Failed to confirm booking: ${e.toString()}');
    }
  }
}
