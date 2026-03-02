import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
import 'package:flutter_online/features/booking/bloc/booking_bloc.dart';
import 'package:flutter_online/features/booking/bloc/booking_event.dart';
import 'package:flutter_online/features/booking/bloc/booking_state.dart';
import 'package:flutter_online/features/booking/data/models/booking_model.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:go_router/go_router.dart';

// Breakpoints: mobile < 768, tablet 768–1024, desktop >= 1024
const double _kBreakpointTablet = 768;
const double _kBreakpointDesktop = 1024;

/// Placeholder image when API does not provide one.
const String _kPlaceholderImage =
    'https://images.pexels.com/photos/265722/pexels-photo-265722.jpeg?auto=compress&cs=tinysrgb&w=800';

enum _LayoutMode { mobile, tablet, desktop }

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  int _selectedFilterIndex = 0; // 0: All, 1: Confirmed, 2: Pending
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final bloc = context.read<BookingBloc>();
    final state = bloc.state;
    if (state is BookingsLoaded &&
        state.hasMore &&
        !state.isLoadingMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      bloc.add(const LoadMoreMyBookings());
    }
  }

  static _LayoutMode _layoutMode(double width) {
    if (width >= _kBreakpointDesktop) return _LayoutMode.desktop;
    if (width >= _kBreakpointTablet) return _LayoutMode.tablet;
    return _LayoutMode.mobile;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final mode = _layoutMode(width);

    return BlocProvider(
      create: (_) => getIt<BookingBloc>()..add(const LoadMyBookings(page: 0)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context, mode),
        body: _buildBody(context, mode),
        bottomNavigationBar: mode == _LayoutMode.mobile ? _buildBottomNav(context) : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, _LayoutMode mode) {
    switch (mode) {
      case _LayoutMode.mobile:
        return _buildMobileAppBar(context);
      case _LayoutMode.tablet:
        return _buildTabletAppBar(context);
      case _LayoutMode.desktop:
        return _buildDesktopAppBar(context);
    }
  }

  /// Mobile: back (left), no center title in app bar; title is in body. Notification (right).
  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primary),
        ),
        onPressed: () => context.go(AppRoutes.home),
      ),
      title: null,
      centerTitle: false,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.notifications_outlined, color: AppColors.primary),
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  /// Tablet: Logo + LuxeEvents (left), Search + Profile (right). No back.
  PreferredSizeWidget _buildTabletAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: null,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.calendar_today, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 10),
          Text(
            'LuxeEvents',
            style: AppTextStyles.headingM.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_outline, color: AppColors.primary, size: 24),
        ),
      ],
    );
  }

  /// Desktop: same as tablet but with more spacing; optional "My Bookings" as active in nav.
  PreferredSizeWidget _buildDesktopAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: null,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.diamond_outlined, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'LuxeEvents',
              style: AppTextStyles.headingM.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 32),
            Text(
              'My Bookings',
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        const SizedBox(width: 16),
        Container(
          margin: const EdgeInsets.only(right: 24),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_outline, color: AppColors.primary, size: 24),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, _LayoutMode mode) {
    switch (mode) {
      case _LayoutMode.mobile:
        return _buildMobileBody(context);
      case _LayoutMode.tablet:
        return _buildTabletBody(context);
      case _LayoutMode.desktop:
        return _buildDesktopBody(context);
    }
  }

  /// Mobile: title + subtitle in body, filter pills, single-column list.
  Widget _buildMobileBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Bookings',
                style: AppTextStyles.headingXL.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your premium event reservations',
                style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        _buildFilterTabs(context, _LayoutMode.mobile),
        Expanded(child: _buildBookingList(context, _LayoutMode.mobile)),
      ],
    );
  }

  /// Tablet: title section, filter bar, 2-column grid. Constrained width.
  Widget _buildTabletBody(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Bookings',
                  style: AppTextStyles.headingXL.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your upcoming luxury experiences',
                  style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                _buildFilterTabs(context, _LayoutMode.tablet),
                const SizedBox(height: 24),
                _buildGrid(context, crossAxisCount: 2, layoutMode: _LayoutMode.tablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Desktop: max-width container, title, filter row, 3-column grid.
  Widget _buildDesktopBody(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Bookings',
                  style: AppTextStyles.headingXL.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your premium event reservations',
                  style: AppTextStyles.bodyL.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),
                _buildFilterTabs(context, _LayoutMode.desktop),
                const SizedBox(height: 32),
                _buildGrid(context, crossAxisCount: 3, layoutMode: _LayoutMode.desktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, _LayoutMode mode) {
    const labels = ['All Bookings', 'Confirmed', 'Pending'];
    final isMobile = mode == _LayoutMode.mobile;
    final horizontalPadding = isMobile ? 16.0 : (mode == _LayoutMode.desktop ? 0.0 : 0.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isActive = _selectedFilterIndex == index;
          return Padding(
            padding: EdgeInsets.only(right: isMobile ? 12 : 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedFilterIndex = index),
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 20,
                    vertical: isMobile ? 10 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        labels[index],
                        style: AppTextStyles.labelM.copyWith(
                          color: isActive ? AppColors.onPrimary : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                      if (index == 0) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: isActive ? AppColors.onPrimary : AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, {required int crossAxisCount, required _LayoutMode layoutMode}) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state is BookingError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    onPressed: () => context.read<BookingBloc>().add(const LoadMyBookings(page: 0)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is BookingsLoaded) {
          final bookings = state.bookings;
          if (bookings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: AppColors.textDisabled),
                    const SizedBox(height: 16),
                    Text(
                      'No bookings yet',
                      style: AppTextStyles.headingM.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: bookings.length,
                itemBuilder: (context, index) => _BookingCard(
                  booking: bookings[index],
                  layoutMode: layoutMode,
                  compact: false,
                  showBottomMargin: false,
                ),
              ),
              if (state.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  ),
                ),
            ],
          );
        }
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      },
    );
  }

  Widget _buildBookingList(BuildContext context, _LayoutMode mode) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state is BookingError) {
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
                    onPressed: () => context.read<BookingBloc>().add(const LoadMyBookings(page: 0)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is BookingsLoaded) {
          final bookings = state.bookings;
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: AppColors.textDisabled),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: AppTextStyles.headingM.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: bookings.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= bookings.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  ),
                );
              }
              return _BookingCard(
                booking: bookings[index],
                layoutMode: _LayoutMode.mobile,
                compact: true,
                showBottomMargin: true,
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined, label: 'HOME', onTap: () => context.go(AppRoutes.home)),
              _NavItem(
                icon: Icons.calendar_today,
                label: 'BOOKINGS',
                isActive: true,
                onTap: () {},
              ),
              _NavItem(icon: Icons.photo_library_outlined, label: 'GALLERY', onTap: () {}),
              _NavItem(icon: Icons.person_outline, label: 'PROFILE', onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final _LayoutMode layoutMode;
  final bool compact;
  final bool showBottomMargin;

  const _BookingCard({
    required this.booking,
    required this.layoutMode,
    required this.compact,
    this.showBottomMargin = false,
  });

  String get _statusLabel => booking.status.toUpperCase();

  bool get _isConfirmed =>
      booking.status.toUpperCase() == 'CONFIRMED';

  String get _paymentSubtext =>
      booking.paymentStatus?.toUpperCase() ?? 'PENDING';

  String get _dateTime {
    final d = booking.eventDate;
    final hour = d.hour;
    final minute = d.minute;
    if (hour == 0 && minute == 0) {
      const months = 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';
      final parts = months.split(',');
      final month = d.month <= 12 ? parts[d.month - 1] : '';
      return '${d.day} $month ${d.year}';
    }
    return '${d.day}/${d.month}/${d.year} • ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String get _location => booking.fullAddress?.isNotEmpty == true
      ? booking.fullAddress!
      : booking.city;

  String get _price {
    if (booking.totalAmount >= 100000) {
      return '₹${(booking.totalAmount / 100000).toStringAsFixed(1)}L';
    }
    return '₹${booking.totalAmount.toStringAsFixed(0)}';
  }

  bool get _isPaymentAction =>
      booking.paymentStatus == null ||
      booking.paymentStatus!.toUpperCase() == 'PENDING';

  String get _actionLabel =>
      _isPaymentAction ? 'Complete Payment' : 'View Details';

  @override
  Widget build(BuildContext context) {
    final imageHeight = compact ? 160.0 : 200.0;
    final padding = compact ? 14.0 : 16.0;

    return Container(
      margin: EdgeInsets.only(bottom: showBottomMargin ? 20 : 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Image.network(
                  _kPlaceholderImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.divider,
                    child: Icon(Icons.image_not_supported, size: 48, color: AppColors.textDisabled),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isConfirmed ? AppColors.success : AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel,
                    style: AppTextStyles.labelS.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.eventType.toUpperCase(),
                            style: AppTextStyles.labelS.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.decorationTitle,
                            style: AppTextStyles.headingM.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontSize: compact ? 16 : 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _price,
                          style: AppTextStyles.headingS.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _paymentSubtext,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _dateTime,
                        style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _location,
                        style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(AppRoutes.bookingDetailPath(booking.bookingId));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPaymentAction ? AppColors.secondary : AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: compact ? 12 : 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_actionLabel, style: AppTextStyles.buttonPrimary),
                        const SizedBox(width: 8),
                        Icon(
                          _isPaymentAction ? Icons.credit_card : Icons.arrow_forward,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 24,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
