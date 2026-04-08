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

const double _kBreakpointTablet = 768;
const double _kBreakpointDesktop = 1024;
const double _kCardRadius = 24;
const double _kMaxWidthDesktop = 1200;

const String _kHeroPlaceholder =
    'https://images.pexels.com/photos/265722/pexels-photo-265722.jpeg?auto=compress&cs=tinysrgb&w=1200';

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

String _paymentModeDisplay(String? mode) {
  if (mode == null || mode.isEmpty) return '—';
  if (mode.toUpperCase() == 'ONLINE') return 'Online Payment';
  return 'Settle at Venue';
}

String _statusDisplay(String? value) {
  if (value == null || value.isEmpty) return '—';
  final u = value.toUpperCase();
  if (u == 'INITIATED') return 'Initiated';
  if (u == 'SUCCESS') return 'Confirmed';
  if (u == 'FAILED') return 'Failed';
  if (u == 'PENDING') return 'Pending';
  return value;
}

class BookingDetailPage extends StatefulWidget {
  final String? bookingId;

  const BookingDetailPage({super.key, this.bookingId});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  bool _isDesktop(double width) => width >= _kBreakpointDesktop;
  bool _isMobile(double width) => width < _kBreakpointTablet;

  @override
  Widget build(BuildContext context) {
    final bookingId = widget.bookingId ?? '';
    return BlocProvider(
      create: (_) => getIt<BookingDetailBloc>()..add(LoadBookingDetail(bookingId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
            onPressed: () => context.go(AppRoutes.myBookings),
          ),
          title: Text(
            'Reservation Details',
            style: AppTextStyles.headingM,
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<BookingDetailBloc, BookingDetailState>(
          listener: (context, state) {
            if (state is BookingDetailCancelSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reservation cancelled successfully')),
              );
              context.go(AppRoutes.myBookings);
            }
            if (state is BookingDetailCancelFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
              context.read<BookingDetailBloc>().add(LoadBookingDetail(state.bookingId));
            }
          },
          builder: (context, state) {
            if (state is BookingDetailLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state is BookingDetailError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 24),
                      Text(state.message, style: AppTextStyles.bodyL, textAlign: TextAlign.center),
                      const SizedBox(height: 32),
                      TextButton.icon(
                        onPressed: () => context.read<BookingDetailBloc>().add(LoadBookingDetail(bookingId)),
                        icon: const Icon(Icons.refresh),
                        label: Text('RETRY LOADING', style: AppTextStyles.labelM),
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
    final totalAmountStr = '₹${b.totalAmount.toStringAsFixed(0)}';
    final paymentModeStr = _paymentModeDisplay(b.paymentMode);
    final bookingStatusStr = _statusDisplay(b.bookingStatus);
    final paymentStatusStr = _statusDisplay(b.paymentStatus);
    final venueName = b.address?.venueName ?? 'Private Location';
    final fullAddress = b.address?.displayLine.isNotEmpty == true 
        ? b.address!.displayLine 
        : (b.address?.fullAddress ?? 'Address details unavailable');

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kMaxWidthDesktop),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _HeroSection(
                            imageUrl: _kHeroPlaceholder,
                            title: b.eventTitle,
                            bookingId: b.bookingId,
                            status: bookingStatusStr,
                            date: eventDateStr,
                          ),
                          const SizedBox(height: 32),
                          _DetailSection(
                            title: 'Experience Details',
                            icon: Icons.auto_awesome_outlined,
                            children: [
                              _DetailRow(label: 'Specialization', value: b.eventType),
                              _DetailRow(label: 'Total Investment', value: totalAmountStr, isHighlight: true),
                              _DetailRow(label: 'Payment Mode', value: paymentModeStr),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _LocationCard(venue: venueName, address: fullAddress),
                          const SizedBox(height: 32),
                          _ActionSection(
                            bookingId: b.bookingId,
                            status: bookingStatusStr,
                            isCancelling: isCancelling,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _HeroSection(
                      imageUrl: _kHeroPlaceholder,
                      title: b.eventTitle,
                      bookingId: b.bookingId,
                      status: bookingStatusStr,
                      date: eventDateStr,
                    ),
                    const SizedBox(height: 32),
                    _DetailSection(
                      title: 'Experience Details',
                      icon: Icons.auto_awesome_outlined,
                      children: [
                        _DetailRow(label: 'Specialization', value: b.eventType),
                        _DetailRow(label: 'Total Investment', value: totalAmountStr, isHighlight: true),
                        _DetailRow(label: 'Payment Mode', value: paymentModeStr),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _LocationCard(venue: venueName, address: fullAddress),
                    const SizedBox(height: 32),
                    _ActionSection(
                      bookingId: b.bookingId,
                      status: bookingStatusStr,
                      isCancelling: isCancelling,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String bookingId;
  final String status;
  final String date;

  const _HeroSection({
    required this.imageUrl,
    required this.title,
    required this.bookingId,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_kCardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusTag(label: status.toUpperCase()),
                    Text(
                      'ID: $bookingId',
                      style: AppTextStyles.labelS.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: AppTextStyles.headingL.copyWith(color: Colors.white, fontSize: 26),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(date, style: AppTextStyles.bodyS.copyWith(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String label;

  const _StatusTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = label.contains('CONFIRMED') || label.contains('SUCCESS');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isConfirmed ? AppColors.accentRose.withOpacity(0.8) : Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelS.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(title.toUpperCase(), style: AppTextStyles.labelM.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.textHint)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _DetailRow({required this.label, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style: isHighlight 
                ? AppTextStyles.headingS.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)
                : AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String venue;
  final String address;

  const _LocationCard({required this.venue, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text('VENUE LOCATION', style: AppTextStyles.labelM.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.textHint)),
            ],
          ),
          const SizedBox(height: 20),
          Text(venue, style: AppTextStyles.headingS),
          const SizedBox(height: 8),
          Text(address, style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 24),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('GET DIRECTIONS', style: AppTextStyles.labelM.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  final String bookingId;
  final String status;
  final bool isCancelling;

  const _ActionSection({
    required this.bookingId,
    required this.status,
    required this.isCancelling,
  });

  @override
  Widget build(BuildContext context) {
    final canCancel = !status.toUpperCase().contains('CANCELLED');

    return Column(
      children: [
        if (canCancel)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isCancelling 
                  ? null 
                  : () => _showCancelDialog(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isCancelling
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error))
                  : Text('CANCEL RESERVATION', style: AppTextStyles.labelM.copyWith(color: AppColors.error, fontWeight: FontWeight.w800)),
            ),
          ),
        const SizedBox(height: 20),
        Text(
          'Need help with this booking?',
          style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () {},
          child: Text('Contact Meeveduka Support', style: AppTextStyles.bodyS.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Cancel Reservation', style: AppTextStyles.headingS),
        content: Text('Are you sure you want to cancel this curated experience? This action cannot be undone.', style: AppTextStyles.bodyM),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('NO, KEEP IT', style: AppTextStyles.labelM),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingDetailBloc>().add(CancelBooking(bookingId));
            },
            child: Text('YES, CANCEL', style: AppTextStyles.labelM.copyWith(color: AppColors.error, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
