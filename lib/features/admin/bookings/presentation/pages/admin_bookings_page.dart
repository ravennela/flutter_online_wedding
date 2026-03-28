import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/admin/presentation/widgets/admin_scaffold.dart';
import 'package:flutter_online/di/service_locator.dart';
import '../bloc/admin_bookings_bloc.dart';
import '../widgets/booking_stats_row.dart';
import '../widgets/booking_filter_bar.dart';
import '../widgets/booking_table.dart';
import '../widgets/booking_card.dart';
import '../widgets/pagination_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_skeleton.dart';
import '../../models/admin_booking_ui_model.dart';

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AdminBookingsBloc>()
        ..add(const FetchEventTypes())
        ..add(const FetchAdminBookings()),
      child: const AdminBookingsView(),
    );
  }
}

class AdminBookingsView extends StatelessWidget {
  const AdminBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Booking Management',
      selectedIndex: 2,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          final padding = isMobile ? 16.0 : 32.0;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminBookingsBloc>().add(
                const FetchAdminBookings(isRefresh: true),
              );
            },
            child: BlocListener<AdminBookingsBloc, AdminBookingsState>(
              listener: (context, state) {
                if (state.status == AdminBookingsStatus.updateSuccess ||
                    state.status == AdminBookingsStatus.cancelSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.status == AdminBookingsStatus.cancelSuccess
                            ? 'Booking cancelled successfully!'
                            : 'Booking status updated successfully!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                if (state.status == AdminBookingsStatus.updateFailure ||
                    state.status == AdminBookingsStatus.cancelFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.errorMessage ?? 'Failed to process request',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                physics: const AlwaysScrollableScrollPhysics(),
                child: BlocBuilder<AdminBookingsBloc, AdminBookingsState>(
                  builder: (context, state) {
                    return Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context),
                            const SizedBox(height: 32),

                            BookingStatsRow(stats: _getMockStats()),
                            const SizedBox(height: 32),
                            const BookingFilterBar(),
                            const SizedBox(height: 24),


                            if (state.status == AdminBookingsStatus.loading &&
                                state.bookings.isEmpty)
                              const BookingListSkeleton()
                            else if (state.status ==
                                AdminBookingsStatus.failure)
                              EmptyStateWidget(
                                title: 'Error Loading Bookings',
                                subtitle:
                                    state.errorMessage ??
                                    'Please check your connection.',
                                icon: Icons.error_outline,
                                onAction: () => context
                                    .read<AdminBookingsBloc>()
                                    .add(const FetchAdminBookings()),
                                actionLabel: 'Retry',
                              )
                            else ...[
                              _buildBookingList(
                                context,
                                state,
                                isMobile,
                                isTablet,
                              ),
                              const SizedBox(height: 24),
                              if (state.bookings.isNotEmpty)
                                PaginationWidget(
                                  currentPage: state.currentPage + 1,
                                  totalPages: state.totalPages,
                                  pageSize: state.pageSize,
                                  totalItems: state.totalItems,
                                  onPageChanged: (page) => context
                                      .read<AdminBookingsBloc>()
                                      .add(ChangePage(page - 1)),
                                  onPageSizeChanged: (size) => context
                                      .read<AdminBookingsBloc>()
                                      .add(ChangePageSize(size)),
                                ),
                            ],
                            const SizedBox(height: 48),
                          ],
                        ),
                        if (state.status == AdminBookingsStatus.updating ||
                            state.status == AdminBookingsStatus.cancelling)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black12,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Management',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1F36),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage all event reservations, payments, and vendor assignments.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    AdminBookingsState state,
    bool isMobile,
    bool isTablet,
  ) {
    if (state.status == AdminBookingsStatus.success && state.bookings.isEmpty) {
      return const EmptyStateWidget(
        title: 'No bookings found',
        subtitle:
            'Try adjusting your filters or search terms to find what you are looking for.',
      );
    }

    if (isMobile) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.bookings.length,
        itemBuilder: (context, index) =>
            BookingCard(booking: state.bookings[index]),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: BookingTable(bookings: state.bookings),
    );
  }

  List<BookingStatsModel> _getMockStats() {
    return [
      BookingStatsModel(
        label: 'Total Bookings',
        value: '1,284',
        percentage: 12,
        isIncrease: true,
        color: Colors.blue,
        progress: 0.7,
      ),
      BookingStatsModel(
        label: 'Requested',
        value: '156',
        percentage: 5,
        isIncrease: true,
        color: Colors.orange,
        progress: 0.3,
      ),
      BookingStatsModel(
        label: 'Confirmed',
        value: '892',
        percentage: 2,
        isIncrease: false,
        color: Colors.green,
        progress: 0.8,
      ),
      BookingStatsModel(
        label: 'Cancelled',
        value: '42',
        percentage: 1,
        isIncrease: true,
        color: Colors.red,
        progress: 0.1,
      ),
      BookingStatsModel(
        label: 'Revenue',
        value: '128.5k',
        percentage: 18,
        isIncrease: true,
        color: Colors.purple,
        progress: 0.6,
      ),
    ];
  }
}
