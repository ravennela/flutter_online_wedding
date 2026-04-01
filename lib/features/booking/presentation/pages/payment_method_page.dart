import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/booking/bloc/booking_bloc.dart';
import 'package:flutter_online/features/booking/bloc/booking_event.dart';
import 'package:flutter_online/features/booking/bloc/booking_state.dart';
import 'package:flutter_online/features/booking/domain/models/booking_args.dart';
import 'package:flutter_online/features/payment/bloc/payment_bloc.dart';
import 'package:flutter_online/features/payment/bloc/payment_event.dart';
import 'package:flutter_online/features/payment/bloc/payment_state.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_online/features/booking/data/models/booking_model.dart';
import 'package:flutter_online/features/payment/domain/entities/razorpay_order_entity.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:flutter_online/core/config/flavor_config.dart';
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
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _createdBookingId;

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

    if (_isOnlinePayment) {
      // Step 1: Create booking first; on success we will create Razorpay order and open checkout
      context.read<BookingBloc>().add(CreateBooking(
            detail.eventTypeId ?? '',
            bookingData,
          ));
    } else {
      context.read<BookingBloc>().add(CreateBooking(
            detail.eventTypeId ?? '',
            bookingData,
          ));
    }
  }

  void _openRazorpay(RazorpayOrderEntity response) {
    _createdBookingId = response.bookingId; // Store the ID returned from backend
    
    var options = {
      'key': response.key.isNotEmpty ? response.key : FlavorConfig.instance.razorpayKey,
      'amount': response.amount, // already in paise from backend
      'name': 'Online Wedding Planner',
      'order_id': response.orderId,
      'description': 'Booking for ${widget.args.decorationDetail.name}',
      'timeout': 300, // in seconds
      'prefill': {
        'contact': widget.args.address.mobileNumber,
        'email': '', // Add email if available
      },
      'theme': {
        'color': '#2563EB',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening Razorpay: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BookingBloc, BookingState>(
            listener: (context, state) {
              if (state is BookingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is BookingCreated) {
                _createdBooking = state.booking;
                if (_isOnlinePayment) {
                  // Step 2: Create Ra     zorpay order with booking id; then open checkout
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
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is RazorpayOrderCreated) {
                _openRazorpay(state.response);
              }
            },
          ),
        ],
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 1024) {
                          return _buildDesktopLayout();
                        } else if (constraints.maxWidth >= 768) {
                          return _buildTabletLayout();
                        } else {
                          return _buildMobileLayout();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Loading Overlay
            BlocBuilder<BookingBloc, BookingState>(
              builder: (context, bookingState) {
                return BlocBuilder<PaymentBloc, PaymentState>(
                  builder: (context, paymentState) {
                    if (bookingState is BookingLoading || paymentState is PaymentLoading) {
                      return Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                onPressed: () => context.pop(),
              ),
              const Expanded(
                child: Column(
                  children: [
                    Text(
                      'STEP 3 OF 4',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'PROGRESS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    Text(
                      '75%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Choose your payment method',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select how you\'d like to settle your booking deposit.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTitleSection(),
                const SizedBox(height: 32),
                _buildPaymentOptions(),
                const SizedBox(height: 24),
                _buildBookingSummary(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _buildBottomFixedCTA(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(),
                      const SizedBox(height: 32),
                      _buildPaymentOptions(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildBookingSummary(),
                    const SizedBox(height: 24),
                    _buildCTA(),
                    const SizedBox(height: 16),
                  
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(),
                      const SizedBox(height: 48),
                      _buildPaymentOptions(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 60),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBookingSummary(isDesktop: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      children: [
        _buildPaymentOptionCard(
          title: 'Pay Online',
          subtitle: 'UPI, Card, Net Banking via Razorpay',
          isOnline: true,
          isRecommended: true,
        ),
        const SizedBox(height: 16),
        _buildPaymentOptionCard(
          title: 'Pay at Venue',
          subtitle: 'No online payment required now',
          isOnline: false,
        ),
      ],
    );
  }

  Widget _buildPaymentOptionCard({
    required String title,
    required String subtitle,
    required bool isOnline,
    bool isRecommended = false,
  }) {
    final isSelected = _isOnlinePayment == isOnline;
    return GestureDetector(
      onTap: () => setState(() => _isOnlinePayment = isOnline),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isOnline ? Icons.account_balance_wallet_outlined : Icons.store_outlined,
                    color: const Color(0xFF2563EB),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                      width: isSelected ? 8 : 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isRecommended)
            Positioned(
              top: -12,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary({bool isDesktop = false}) {
    final detail = widget.args.decorationDetail;
    final address = widget.args.address;
    final selectedDate = widget.args.selectedDate ?? DateTime(2026, 3, 20);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const Text(
              'BOOKING SUMMARY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildSummaryRow(Icons.celebration_outlined, 'Event', detail.eventTypeName),
                const SizedBox(height: 16),
                _buildSummaryRow(Icons.calendar_month_outlined, 'Date', DateFormat('MMMM dd, yyyy').format(selectedDate)),
                const SizedBox(height: 16),
                _buildSummaryRow(Icons.access_time_outlined, 'Time', widget.args.selectedTime?.format(context) ?? 'Not Selected'),
                const SizedBox(height: 16),
                _buildSummaryRow(Icons.location_on_outlined, 'Location', '${address.area}, ${address.city}'),
                const SizedBox(height: 24),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    Text(
                      detail.formattedPrice,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
                if (isDesktop) ...[
                  const SizedBox(height: 32),
                  _buildCTA(),
                  
                
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomFixedCTA() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCTA(),
          const SizedBox(height: 12),
         
        ],
      ),
    );
  }

  Widget _buildCTA() {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, bookingState) {
        return BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, paymentState) {
            final isLoading = bookingState is BookingLoading || paymentState is PaymentLoading;

            return SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: isLoading ? null : _proceedWithBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isOnlinePayment ? 'Proceed to Secure Payment' : 'Confirm Booking',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }

  
}
