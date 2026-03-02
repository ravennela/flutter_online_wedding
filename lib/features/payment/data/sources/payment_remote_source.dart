import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/razorpay_order_response.dart';

/// Creates a Razorpay order for an existing booking.
/// Backend expects: POST /api/payments/create-order with body { bookingId: UUID, amount: number (INR) }.
abstract class PaymentRemoteSource {
  Future<RazorpayOrderResponse> createOrder(String bookingId, double amountInRupees);
}

class PaymentRemoteSourceImpl implements PaymentRemoteSource {
  final ApiClient apiClient;

  PaymentRemoteSourceImpl(this.apiClient);

  @override
  Future<RazorpayOrderResponse> createOrder(String bookingId, double amountInRupees) async {
    try {
      final response = await apiClient.post(
        ApiConstants.createOrder,
        data: {
          'bookingId': bookingId,
          'amount': amountInRupees,
        },
      );

      if (response.data is! Map) {
        throw ServerException('Invalid response format from server');
      }

      final data = response.data as Map<String, dynamic>;
      return RazorpayOrderResponse.fromJson(data, bookingId: bookingId);
    } catch (e) {
      throw ServerException('Failed to create Razorpay order: ${e.toString()}');
    }
  }
}


