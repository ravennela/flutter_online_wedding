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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, _LayoutMode mode) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
        onPressed: () => context.go(AppRoutes.home),
      ),
      title: Text(
        'Meeveduka',
        style: AppTextStyles.displaySerif.copyWith(fontSize: 18),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(BuildContext context, _LayoutMode mode) {
    switch (mode) {
      case _LayoutMode.mobile:
        return _buildMobileBody(context);
      default:
        return _buildCenterBody(context, mode);
    }
  }

  Widget _buildMobileBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Reservations',
                style: AppTextStyles.headingL,
              ),
              const SizedBox(height: 4),
              Text(
                'Review and manage your curated experiences',
                style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        _buildFilterTabs(context, _LayoutMode.mobile),
        const SizedBox(height: 16),
        Expanded(child: _buildBookingList(context, _LayoutMode.mobile)),
      ],
    );
  }

  Widget _buildCenterBody(BuildContext context, _LayoutMode mode) {
    final isDesktop = mode == _LayoutMode.desktop;
    return SingleChildScrollView(
      controller: _scrollController,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : 900),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Reservations',
                          style: AppTextStyles.headingXL,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Review and manage your curated experiences across all your special occasions.',
                          style: AppTextStyles.bodyL.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildFilterTabs(context, mode),
                const SizedBox(height: 32),
                _buildGrid(context, 
                  crossAxisCount: isDesktop ? 3 : 2, 
                  layoutMode: mode
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, _LayoutMode mode) {
    final labels = ['All', 'Confirmed', 'Pending'];
    final isMobile = mode == _LayoutMode.mobile;

    return Container(
      height: 48,
      margin: EdgeInsets.only(left: isMobile ? 24 : 0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isActive = _selectedFilterIndex == index;
          return ChoiceChip(
            label: Text(labels[index].toUpperCase()),
            selected: isActive,
            onSelected: (selected) {
              if (selected) setState(() => _selectedFilterIndex = index);
            },
            selectedColor: AppColors.textPrimary,
            backgroundColor: AppColors.surface,
            labelStyle: AppTextStyles.labelS.copyWith(
              color: isActive ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isActive ? AppColors.textPrimary : AppColors.divider,
                width: 1,
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context, {required int crossAxisCount, required _LayoutMode layoutMode}) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(80),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state is BookingsLoaded) {
          final bookings = state.bookings;
          if (bookings.isEmpty) return _buildEmptyState();
          
          return Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 32,
                ),
                itemCount: bookings.length,
                itemBuilder: (context, index) => _BookingCard(
                  booking: bookings[index],
                  layoutMode: layoutMode,
                ),
              ),
              if (state.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBookingList(BuildContext context, _LayoutMode mode) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is BookingsLoaded) {
          final bookings = state.bookings;
          if (bookings.isEmpty) return _buildEmptyState();
          
          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            itemCount: bookings.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              if (index >= bookings.length) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ));
              }
              return _BookingCard(
                booking: bookings[index],
                layoutMode: mode,
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.event_note_outlined, size: 64, color: AppColors.accentRose),
            ),
            const SizedBox(height: 32),
            Text('No Reservations Found', style: AppTextStyles.headingM),
            const SizedBox(height: 12),
            Text(
              'Your curated wedding experiences will appear here once you reserve them.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('EXPLORE COLLECTIONS', style: AppTextStyles.labelM.copyWith(color: Colors.white, letterSpacing: 1.2)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final _LayoutMode layoutMode;

  const _BookingCard({
    required this.booking,
    required this.layoutMode,
  });

  @override
  Widget build(BuildContext context) {
    final confirmed = booking.status.toUpperCase() == 'CONFIRMED' || booking.status.toUpperCase() == 'SUCCESS';
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('${AppRoutes.bookingDetail}/${booking.bookingId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.8,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      _kPlaceholderImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: confirmed ? const Color(0xFFE8F5E9) : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking.status.toUpperCase(),
                        style: AppTextStyles.labelS.copyWith(
                          color: confirmed ? const Color(0xFF2E7D32) : const Color(0xFFC2410C),
                          fontWeight: FontWeight.w900,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.eventType.toUpperCase(),
                    style: AppTextStyles.labelS.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    booking.decorationTitle,
                    style: AppTextStyles.headingS.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 8),
                      Text(
                        _formatDateDisplay(booking.eventDate),
                        style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.city,
                          style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${booking.totalAmount.toInt()}',
                        style: AppTextStyles.price.copyWith(fontSize: 18, color: AppColors.textPrimary),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textHint),
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

  String _formatDateDisplay(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }
}
