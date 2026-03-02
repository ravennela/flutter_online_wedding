import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
import 'package:flutter_online/features/booking/data/models/booking_detail_model.dart';
import 'package:flutter_online/features/booking/presentation/bloc/booking_detail_bloc.dart';
import 'package:flutter_online/features/booking/presentation/bloc/booking_detail_event.dart';
import 'package:flutter_online/features/booking/presentation/bloc/booking_detail_state.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:go_router/go_router.dart';

// Breakpoints: mobile < 768, tablet 768–1024, desktop >= 1024
const double _kBreakpointTablet = 768;
const double _kBreakpointDesktop = 1024;
const double _kCardRadius = 16;
const double _kMaxWidthDesktop = 1320;

const String _kHeroImage =
    'https://images.pexels.com/photos/265722/pexels-photo-265722.jpeg?auto=compress&cs=tinysrgb&w=1200';

/// Formats date string (e.g. "2026-03-20" or ISO) to "20 Mar 2026".
String _formatDate(String? value) {
  if (value == null || value.isEmpty) return '—';
  try {
    final d = value.length > 10 ? DateTime.parse(value) : DateTime.parse('$value:00:00');
    const months = 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';
    return '${d.day} ${months.split(',')[d.month - 1]} ${d.year}';
  } catch (_) {
    return value;
  }
}

/// Formats ISO date-time to short date for display.
String _formatDateTime(String? value) {
  if (value == null || value.isEmpty) return '—';
  return _formatDate(value);
}

/// Payment mode display: ONLINE -> "Online", else "Pay at Venue".
String _paymentModeDisplay(String? mode) {
  if (mode == null || mode.isEmpty) return '—';
  if (mode.toUpperCase() == 'ONLINE') return 'Online';
  return 'Pay at Venue';
}

/// Payment/booking status for badge: normalize INITIATED etc.
String _statusDisplay(String? value) {
  if (value == null || value.isEmpty) return '—';
  final u = value.toUpperCase();
  if (u == 'INITIATED') return 'Initiated';
  if (u == 'SUCCESS') return 'Success';
  if (u == 'FAILED') return 'Failed';
  if (u == 'PENDING') return 'Pending';
  return value;
}

/// Booking details screen – loads from API via bloc.
class BookingDetailPage extends StatefulWidget {
  final String? bookingId;

  const BookingDetailPage({super.key, this.bookingId});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  bool _isDesktop(double width) => width >= _kBreakpointDesktop;
  bool _isTablet(double width) =>
      width >= _kBreakpointTablet && width < _kBreakpointDesktop;
  bool _isMobile(double width) => width < _kBreakpointTablet;

  @override
  Widget build(BuildContext context) {
    final bookingId = widget.bookingId ?? '';
    return BlocProvider(
      create: (_) => getIt<BookingDetailBloc>()..add(LoadBookingDetail(bookingId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context, MediaQuery.of(context).size.width),
        body: BlocConsumer<BookingDetailBloc, BookingDetailState>(
          listener: (context, state) {
            if (state is BookingDetailCancelSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled successfully')),
              );
              context.go(AppRoutes.myBookings);
            }
            if (state is BookingDetailCancelFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              context.read<BookingDetailBloc>().add(LoadBookingDetail(state.bookingId));
            }
          },
          builder: (context, state) {
            if (state is BookingDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is BookingDetailError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () => context.read<BookingDetailBloc>().add(LoadBookingDetail(bookingId)),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is BookingDetailLoaded) {
              return _buildContent(context, state.booking, isCancelling: false);
            }
            if (state is BookingDetailCancelInProgress) {
              return _buildContent(context, state.booking, isCancelling: true);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BookingDetailModel b, {bool isCancelling = false}) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = _isDesktop(width);

    final eventDateStr = _formatDate(b.eventDate);
    final bookingCreatedStr = _formatDateTime(b.bookingCreatedAt);
    final totalAmountStr = b.totalAmount >= 100000
        ? '₹ ${(b.totalAmount / 100000).toStringAsFixed(1)}L'
        : '₹ ${b.totalAmount.toStringAsFixed(0)}';
    final paymentModeStr = _paymentModeDisplay(b.paymentMode);
    final bookingStatusStr = _statusDisplay(b.bookingStatus);
    final paymentStatusStr = _statusDisplay(b.paymentStatus);
    final guestCountStr = b.guestCount != null ? '${b.guestCount} Guests' : '—';
    final venueName = b.address?.venueName ?? '—';
    final fullAddress = b.address?.displayLine.isNotEmpty == true ? b.address!.displayLine : (b.address?.fullAddress ?? '—');
    final razorpayOrderId = b.payment?.razorpayOrderId ?? '—';
    final razorpayPaymentId = b.payment?.razorpayPaymentId ?? '—';
    final isOnline = b.paymentMode.toUpperCase() == 'ONLINE';

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kMaxWidthDesktop),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : (_isTablet(width) ? 24 : 16),
              vertical: isDesktop ? 32 : 24,
            ),
            child: isDesktop
                ? _buildDesktopLayout(
                    eventDateStr: eventDateStr,
                    bookingCreatedStr: bookingCreatedStr,
                    totalAmountStr: totalAmountStr,
                    paymentModeStr: paymentModeStr,
                    bookingStatusStr: bookingStatusStr,
                    paymentStatusStr: paymentStatusStr,
                    guestCountStr: guestCountStr,
                    venueName: venueName,
                    fullAddress: fullAddress,
                    razorpayOrderId: razorpayOrderId,
                    razorpayPaymentId: razorpayPaymentId,
                    isOnline: isOnline,
                    b: b,
                    isCancelling: isCancelling,
                  )
                : _buildMobileTabletLayout(
                    width: width,
                    eventDateStr: eventDateStr,
                    bookingCreatedStr: bookingCreatedStr,
                    totalAmountStr: totalAmountStr,
                    paymentModeStr: paymentModeStr,
                    bookingStatusStr: bookingStatusStr,
                    paymentStatusStr: paymentStatusStr,
                    guestCountStr: guestCountStr,
                    venueName: venueName,
                    fullAddress: fullAddress,
                    razorpayOrderId: razorpayOrderId,
                    razorpayPaymentId: razorpayPaymentId,
                    isOnline: isOnline,
                    b: b,
                    isCancelling: isCancelling,
                  ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, double width) {
    final isMobile = _isMobile(width);
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: isMobile ? 18 : 20, color: AppColors.textPrimary),
        onPressed: () => context.go(AppRoutes.myBookings),
      ),
      centerTitle: true,
      title: Text(
        'Booking Details',
        style: AppTextStyles.headingM.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, color: AppColors.textPrimary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildDesktopLayout({
    required String eventDateStr,
    required String bookingCreatedStr,
    required String totalAmountStr,
    required String paymentModeStr,
    required String bookingStatusStr,
    required String paymentStatusStr,
    required String guestCountStr,
    required String venueName,
    required String fullAddress,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required bool isOnline,
    required BookingDetailModel b,
    bool isCancelling = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroSection(
                imageUrl: _kHeroImage,
                eventTitle: b.eventTitle.isNotEmpty ? b.eventTitle : '—',
                bookingId: b.bookingId,
                status: bookingStatusStr,
                paymentStatus: paymentStatusStr,
                eventDate: eventDateStr,
              ),
              const SizedBox(height: 24),
              _BookingSummaryCard(
                totalAmount: totalAmountStr,
                paymentMode: paymentModeStr,
                bookingCreated: bookingCreatedStr,
              ),
              const SizedBox(height: 24),
              _EventInformationCard(
                eventDate: eventDateStr,
                eventTime: '—',
                eventType: b.eventType.isNotEmpty ? b.eventType : '—',
                guestCount: guestCountStr,
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 35,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _EventAddressCard(
                venueName: venueName,
                fullAddress: fullAddress,
              ),
              const SizedBox(height: 24),
              _PaymentDetailsCard(
                paymentMode: paymentModeStr,
                razorpayOrderId: razorpayOrderId,
                razorpayPaymentId: razorpayPaymentId,
                paymentStatus: paymentStatusStr,
                isOnline: isOnline,
              ),
              const SizedBox(height: 24),
              _QuickActionsSection(
                status: bookingStatusStr,
                paymentStatus: paymentStatusStr,
                bookingId: b.bookingId,
                isCancelling: isCancelling,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTabletLayout({
    required double width,
    required String eventDateStr,
    required String bookingCreatedStr,
    required String totalAmountStr,
    required String paymentModeStr,
    required String bookingStatusStr,
    required String paymentStatusStr,
    required String guestCountStr,
    required String venueName,
    required String fullAddress,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required bool isOnline,
    required BookingDetailModel b,
    bool isCancelling = false,
  }) {
    final isTablet = _isTablet(width);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroSection(
          imageUrl: _kHeroImage,
          eventTitle: b.eventTitle.isNotEmpty ? b.eventTitle : '—',
          bookingId: b.bookingId,
          status: bookingStatusStr,
          paymentStatus: paymentStatusStr,
          eventDate: eventDateStr,
        ),
        SizedBox(height: isTablet ? 28 : 20),
        _BookingSummaryCard(
          totalAmount: totalAmountStr,
          paymentMode: paymentModeStr,
          bookingCreated: bookingCreatedStr,
        ),
        SizedBox(height: isTablet ? 28 : 20),
        if (isTablet)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _EventInformationCard(
                  eventDate: eventDateStr,
                  eventTime: '—',
                  eventType: b.eventType.isNotEmpty ? b.eventType : '—',
                  guestCount: guestCountStr,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _EventAddressCard(
                  venueName: venueName,
                  fullAddress: fullAddress,
                ),
              ),
            ],
          )
        else ...[
          _EventInformationCard(
            eventDate: eventDateStr,
            eventTime: '—',
            eventType: b.eventType.isNotEmpty ? b.eventType : '—',
            guestCount: guestCountStr,
          ),
          const SizedBox(height: 20),
          _EventAddressCard(
            venueName: venueName,
            fullAddress: fullAddress,
          ),
        ],
        SizedBox(height: isTablet ? 28 : 20),
        _PaymentDetailsCard(
          paymentMode: paymentModeStr,
          razorpayOrderId: razorpayOrderId,
          razorpayPaymentId: razorpayPaymentId,
          paymentStatus: paymentStatusStr,
          isOnline: isOnline,
        ),
        SizedBox(height: isTablet ? 28 : 20),
        _QuickActionsSection(
          status: bookingStatusStr,
          paymentStatus: paymentStatusStr,
          bookingId: b.bookingId,
          isCancelling: isCancelling,
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final String imageUrl;
  final String eventTitle;
  final String bookingId;
  final String status;
  final String paymentStatus;
  final String eventDate;

  const _HeroSection({
    required this.imageUrl,
    required this.eventTitle,
    required this.bookingId,
    required this.status,
    required this.paymentStatus,
    required this.eventDate,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: Stack(
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.divider,
                  child: const Icon(Icons.image_not_supported, size: 48),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventTitle,
                    style: AppTextStyles.headingL.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'ID: $bookingId',
                        style: AppTextStyles.caption.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(width: 12),
                      _StatusBadge(label: status, type: _BadgeType.booking),
                      const SizedBox(width: 8),
                      _StatusBadge(label: paymentStatus, type: _BadgeType.payment),
                      const Spacer(),
                      Text(
                        eventDate,
                        style: AppTextStyles.bodyS.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _BadgeType { booking, payment }

class _StatusBadge extends StatelessWidget {
  final String label;
  final _BadgeType type;

  const _StatusBadge({required this.label, required this.type});

  Color _backgroundColor() {
    final upper = label.toUpperCase();
    if (type == _BadgeType.booking) {
      if (upper == 'CONFIRMED') return const Color(0xFFE8F5E9);
      if (upper == 'REQUESTED') return const Color(0xFFFFF8E1);
      if (upper == 'CANCELLED') return const Color(0xFFFFEBEE);
    }
    if (type == _BadgeType.payment) {
      if (upper == 'SUCCESS') return const Color(0xFFE8F5E9);
      if (upper == 'PENDING' || upper == 'INITIATED') return const Color(0xFFEEEEEE);
      if (upper == 'FAILED') return const Color(0xFFFFEBEE);
    }
    return AppColors.divider;
  }

  Color _textColor() {
    final upper = label.toUpperCase();
    if (type == _BadgeType.booking) {
      if (upper == 'CONFIRMED') return const Color(0xFF2E7D32);
      if (upper == 'REQUESTED') return const Color(0xFFF57C00);
      if (upper == 'CANCELLED') return AppColors.error;
    }
    if (type == _BadgeType.payment) {
      if (upper == 'SUCCESS') return const Color(0xFF2E7D32);
      if (upper == 'PENDING' || upper == 'INITIATED') return AppColors.textSecondary;
      if (upper == 'FAILED') return AppColors.error;
    }
    return AppColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelS.copyWith(
          color: _textColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BookingSummaryCard extends StatelessWidget {
  final String totalAmount;
  final String paymentMode;
  final String bookingCreated;

  const _BookingSummaryCard({
    required this.totalAmount,
    required this.paymentMode,
    required this.bookingCreated,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BOOKING SUMMARY',
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Total Amount', value: totalAmount, valueStyle: AppTextStyles.headingM.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _InfoRow(label: 'Payment Mode', value: paymentMode),
            const SizedBox(height: 12),
            _InfoRow(label: 'Booking Created', value: bookingCreated),
          ],
        ),
      ),
    );
  }
}

class _EventInformationCard extends StatelessWidget {
  final String eventDate;
  final String eventTime;
  final String eventType;
  final String guestCount;

  const _EventInformationCard({
    required this.eventDate,
    required this.eventTime,
    required this.eventType,
    required this.guestCount,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  'Event Information',
                  style: AppTextStyles.headingS.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _InfoRow(label: 'Date', value: eventDate),
            const SizedBox(height: 12),
            _InfoRow(label: 'Time', value: eventTime),
            const SizedBox(height: 12),
            _InfoRow(label: 'Event Type', value: eventType),
            const SizedBox(height: 12),
            _InfoRow(label: 'Guest Count', value: guestCount),
          ],
        ),
      ),
    );
  }
}

class _EventAddressCard extends StatelessWidget {
  final String venueName;
  final String fullAddress;

  const _EventAddressCard({
    required this.venueName,
    required this.fullAddress,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  'Event Address',
                  style: AppTextStyles.headingS.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              venueName,
              style: AppTextStyles.bodyL.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              fullAddress,
              style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.divider.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.map_outlined, size: 40, color: AppColors.textDisabled),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {},
              child: Text(
                'GET DIRECTIONS',
                style: AppTextStyles.labelM.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentDetailsCard extends StatelessWidget {
  final String paymentMode;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String paymentStatus;
  final bool isOnline;

  const _PaymentDetailsCard({
    required this.paymentMode,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.paymentStatus,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  'Payment Details',
                  style: AppTextStyles.headingS.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isOnline) ...[
              _CopyableField(label: 'Razorpay Order ID', value: razorpayOrderId),
              const SizedBox(height: 12),
              _CopyableField(label: 'Razorpay Payment ID', value: razorpayPaymentId),
              const SizedBox(height: 16),
              _StatusBadge(label: paymentStatus, type: _BadgeType.payment),
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Payment will be collected at the venue.',
                        style: AppTextStyles.bodyS.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CopyableField extends StatelessWidget {
  final String label;
  final String value;

  const _CopyableField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyM,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy_outlined, size: 18, color: AppColors.primary),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 2)),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final String status;
  final String paymentStatus;
  final String bookingId;
  final bool isCancelling;

  const _QuickActionsSection({
    required this.status,
    required this.paymentStatus,
    required this.bookingId,
    this.isCancelling = false,
  });

  @override
  Widget build(BuildContext context) {
    final upper = status.toUpperCase();
    final paymentFailed = paymentStatus.toUpperCase() == 'FAILED';

    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.bolt_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  'Quick Actions',
                  style: AppTextStyles.headingS.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (upper == 'REQUESTED') ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isCancelling
                      ? null
                      : () => context.read<BookingDetailBloc>().add(CancelBooking(bookingId)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isCancelling
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                        )
                      : const Text('Cancel Booking'),
                ),
              ),
            ] else if (upper == 'CONFIRMED' && !paymentFailed) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 20),
                  label: const Text('Download Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.headset_mic_outlined, size: 20, color: AppColors.primary),
                  label: Text('Contact Support', style: TextStyle(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ] else if (paymentFailed) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Retry Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Card extends StatefulWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= _kBreakpointDesktop;
    return MouseRegion(
      onEnter: isDesktop ? (_) => setState(() => _hover = true) : null,
      onExit: isDesktop ? (_) => setState(() => _hover = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(_kCardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hover ? 0.08 : 0.06),
              blurRadius: _hover ? 20 : 16,
              offset: Offset(0, _hover ? 6 : 4),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelS.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: valueStyle ?? AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
