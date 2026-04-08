import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/config/flavor_config.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
import 'package:flutter_online/features/booking/bloc/booking_bloc.dart';
import 'package:flutter_online/features/booking/bloc/booking_event.dart';
import 'package:flutter_online/features/booking/bloc/booking_state.dart';
import 'package:flutter_online/features/booking/data/models/booking_model.dart';
import 'package:flutter_online/features/booking/domain/models/booking_args.dart';
import 'package:flutter_online/features/payment/bloc/payment_bloc.dart';
import 'package:flutter_online/features/payment/bloc/payment_event.dart';
import 'package:flutter_online/features/payment/bloc/payment_state.dart';
import 'package:flutter_online/features/payment/domain/entities/razorpay_order_entity.dart';
import 'package:flutter_online/shared/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_web/razorpay_web.dart';

class PaymentMethodPage extends StatefulWidget {
  final BookingArgs args;

  const PaymentMethodPage({super.key, required this.args});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  bool _isOnlinePayment = true;
  late Razorpay _razorpay;
  BookingModel? _createdBooking;
  String? _createdBookingId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_createdBooking != null || _createdBookingId != null) {
      context.pushReplacement(
        AppRoutes.bookingSuccess,
        extra: {
          'bookingId': _createdBooking?.bookingId ?? _createdBookingId,
          'amount': widget.args.decorationDetail.formattedPrice,
          'date': DateFormat('MMMM dd, yyyy').format(_createdBooking?.eventDate ?? widget.args.selectedDate!),
          'time': _createdBooking?.eventTime ?? widget.args.selectedTime?.format(context),
        },
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message ?? "User cancelled"}'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _proceedWithBooking() {
    final detail = widget.args.decorationDetail;
    final address = widget.args.address;
    final selectedDate = widget.args.selectedDate!;

    final bookingData = {
      'cityId': detail.cityId,
      'decorationId': detail.id,
      'addressId': address.id,
      'eventDate': DateFormat('yyyy-MM-dd').format(selectedDate),
      'eventTime': widget.args.selectedTime != null
          ? '${widget.args.selectedTime!.hour.toString().padLeft(2, '0')}:${widget.args.selectedTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'paymentMode': _isOnlinePayment ? 'ONLINE' : 'PAY_AT_VENUE',
    };

    context.read<BookingBloc>().add(CreateBooking(
          detail.eventTypeId ?? '',
          bookingData,
        ));
  }

  void _openRazorpay(RazorpayOrderEntity response) {
    _createdBookingId = response.bookingId;
    
    var options = {
      'key': response.key.isNotEmpty ? response.key : FlavorConfig.instance.razorpayKey,
      'amount': response.amount,
      'name': 'Meeveduka',
      'order_id': response.orderId,
      'description': 'Booking for ${widget.args.decorationDetail.name}',
      'timeout': 300,
      'prefill': {
        'contact': widget.args.address.mobileNumber,
        'email': '',
      },
      'theme': {
        'color': '#D4AF37', // Gold color for premium feel in Razorpay UI
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening Razorpay: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Confirmation',
          style: AppTextStyles.headingM,
        ),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BookingBloc, BookingState>(
            listener: (context, state) {
              if (state is BookingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is BookingCreated) {
                _createdBooking = state.booking;
                if (_isOnlinePayment) {
                  context.read<PaymentBloc>().add(CreateRazorpayOrder(
                        bookingId: state.booking.bookingId,
                        amountInRupees: widget.args.decorationDetail.price,
                      ));
                } else {
                  context.pushReplacement(
                    AppRoutes.bookingSuccess,
                    extra: {
                      'bookingId': state.booking.bookingId,
                      'amount': widget.args.decorationDetail.formattedPrice,
                      'date': DateFormat('MMMM dd, yyyy').format(state.booking.eventDate),
                      'time': state.booking.eventTime ?? widget.args.selectedTime?.format(context),
                    },
                  );
                }
              }
            },
          ),
          BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is RazorpayOrderCreated) {
                _openRazorpay(state.response);
              }
            },
          ),
        ],
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeading(),
                        const SizedBox(height: 48),
                        _buildPaymentOptions(),
                        const SizedBox(height: 40),
                        _buildBookingSummary(),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomFixedCTA(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RESERVATION STEP 3',
                style: AppTextStyles.labelS.copyWith(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '75% Completed',
                style: AppTextStyles.labelS.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                height: 6,
                width: MediaQuery.of(context).size.width * 0.75,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Philosophy',
          style: AppTextStyles.headingXL,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how you would like to secure your premium wedding experience.',
          style: AppTextStyles.bodyL.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      children: [
        _buildPaymentOptionCard(
          title: 'Secure Online Payment',
          subtitle: 'Instant confirmation via UPI, Cards, or Net Banking',
          isOnline: true,
          icon: Icons.shield_outlined,
          isRecommended: true,
        ),
        const SizedBox(height: 20),
        _buildPaymentOptionCard(
          title: 'Settle at Venue',
          subtitle: 'Pay our executive during the styling process',
          isOnline: false,
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }

  Widget _buildPaymentOptionCard({
    required String title,
    required String subtitle,
    required bool isOnline,
    required IconData icon,
    bool isRecommended = false,
  }) {
    final isSelected = _isOnlinePayment == isOnline;
    return InkWell(
      onTap: () => setState(() => _isOnlinePayment = isOnline),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentRose.withOpacity(0.25) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textHint,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.headingS.copyWith(fontSize: 18),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'RECOMMENDED',
                            style: AppTextStyles.labelS.copyWith(
                              color: AppColors.primary,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: isOnline,
              groupValue: _isOnlinePayment,
              onChanged: (val) => setState(() => _isOnlinePayment = val!),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    final detail = widget.args.decorationDetail;
    final address = widget.args.address;
    final selectedDate = widget.args.selectedDate ?? DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: AppColors.accentRose.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  'FINAL INVESTMENT DETAILS',
                  style: AppTextStyles.labelS.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _SummaryInfoLine(label: 'Experience', value: detail.name),
                _SummaryInfoLine(label: 'Scheduled For', value: DateFormat('MMMM dd, yyyy').format(selectedDate)),
                _SummaryInfoLine(label: 'Time Slot', value: widget.args.selectedTime?.format(context) ?? 'N/A'),
                _SummaryInfoLine(label: 'Location Type', value: address.addressType),
                const SizedBox(height: 24),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Investment',
                      style: AppTextStyles.bodyL.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      detail.formattedPrice,
                      style: AppTextStyles.price.copyWith(fontSize: 28, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomFixedCTA() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, bookingState) {
          return BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, paymentState) {
              final isLoading = bookingState is BookingLoading || paymentState is PaymentLoading;

              return PrimaryButton(
                text: _isOnlinePayment ? 'SECURE RESERVATION' : 'FINALIZE BOOKING',
                isLoading: isLoading,
                onPressed: isLoading ? null : _proceedWithBooking,
              );
            },
          );
        },
      ),
    );
  }
}

class _SummaryInfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryInfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyS.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
