import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/admin/bookings/domain/entities/admin_booking_entity.dart';
import 'package:flutter_online/features/admin/presentation/widgets/admin_scaffold.dart';
import 'package:intl/intl.dart';

import '../../models/admin_booking_ui_model.dart';
import '../bloc/admin_booking_detail_bloc.dart';
import '../widgets/action_buttons_row.dart';
import '../widgets/activity_timeline_card.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/customer_details_card.dart';
import '../widgets/event_info_card.dart';
import '../widgets/payment_history_card.dart';
import '../widgets/status_card.dart';
import '../widgets/vendor_section.dart';
import '../widgets/venue_location_card.dart';
import '../widgets/loading_skeleton.dart';

class AdminBookingDetailPage extends StatelessWidget {
  final String? bookingId;

  const AdminBookingDetailPage({super.key, this.bookingId});

  @override
  Widget build(BuildContext context) {
    final id =
        bookingId ??
        ModalRoute.of(context)?.settings.arguments as String? ??
        '';

    if (id.isEmpty) {
      return const Scaffold(body: Center(child: Text('Invalid Booking ID')));
    }

    return BlocProvider(
      create: (context) =>
          getIt<AdminBookingDetailBloc>()..add(FetchBookingDetail(id)),
      child: AdminScaffold(
        title: 'Booking Detail',
        selectedIndex: 2,
        body: BlocListener<AdminBookingDetailBloc, AdminBookingDetailState>(
          listener: (context, state) {
            if (state.status == AdminBookingDetailStatus.updateSuccess ||
                state.status == AdminBookingDetailStatus.cancelSuccess ||
                state.status == AdminBookingDetailStatus.deAssignSuccess) {
              String successMessage = 'Booking status updated successfully!';
              if (state.status == AdminBookingDetailStatus.cancelSuccess) {
                successMessage = 'Booking cancelled successfully!';
              } else if (state.status ==
                  AdminBookingDetailStatus.deAssignSuccess) {
                successMessage = 'Vendor de-assigned successfully!';
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(successMessage),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state.status == AdminBookingDetailStatus.updateFailure ||
                state.status == AdminBookingDetailStatus.cancelFailure ||
                state.status == AdminBookingDetailStatus.deAssignFailure) {
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
          child: BlocBuilder<AdminBookingDetailBloc, AdminBookingDetailState>(
            builder: (context, state) {
              if (state.status == AdminBookingDetailStatus.loading) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: BookingDetailSkeleton(),
                );
              }

              if (state.status == AdminBookingDetailStatus.failure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage ?? 'Failed to load booking details',
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context
                            .read<AdminBookingDetailBloc>()
                            .add(FetchBookingDetail(id)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if ((state.status == AdminBookingDetailStatus.success ||
                      state.status == AdminBookingDetailStatus.updating ||
                      state.status == AdminBookingDetailStatus.updateSuccess ||
                      state.status == AdminBookingDetailStatus.updateFailure ||
                      state.status == AdminBookingDetailStatus.deAssigning ||
                      state.status ==
                          AdminBookingDetailStatus.deAssignSuccess ||
                      state.status ==
                          AdminBookingDetailStatus.deAssignFailure) &&
                  state.booking != null) {
                final booking = AdminBookingUIModel.fromEntity(state.booking!);
                final vendors = _getVendorsFromEntity(state.booking!);
                final activities = _getActivitiesFromEntity(state.booking!);

                return Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 700;
                        final isTablet =
                            constraints.maxWidth >= 700 &&
                            constraints.maxWidth < 1100;
                        final padding = isMobile ? 16.0 : 32.0;

                        return SingleChildScrollView(
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(context, booking),
                              const SizedBox(height: 32),

                              if (isMobile)
                                _buildMobileLayout(booking, vendors, activities)
                              else if (isTablet)
                                _buildTabletLayout(booking, vendors, activities)
                              else
                                _buildDesktopLayout(
                                  booking,
                                  vendors,
                                  activities,
                                ),

                              const SizedBox(height: 48),
                            ],
                          ),
                        );
                      },
                    ),
                    if (state.status == AdminBookingDetailStatus.updating ||
                        state.status == AdminBookingDetailStatus.cancelling ||
                        state.status == AdminBookingDetailStatus.deAssigning)
                      Container(
                        color: Colors.black26,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AdminBookingUIModel booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            Text(
              'Booking #${booking.bookingCode}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1F36),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Row(
            children: [
              Text(
                'Created on ${DateFormat('MMM dd, yyyy').format(booking.createdAt)}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(width: 24),
              Expanded(child: ActionButtonsRow(booking: booking)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    AdminBookingUIModel booking,
    List<VendorModel> vendors,
    List<ActivityModel> activities,
  ) {
    return Column(
      children: [
        StatusCard(booking: booking),
        const SizedBox(height: 16),
        BookingSummaryCard(booking: booking),
        const SizedBox(height: 16),
        CustomerDetailsCard(booking: booking),
        const SizedBox(height: 16),
        EventInfoCard(booking: booking),
        const SizedBox(height: 16),
        VendorSection(vendors: vendors, booking: booking),
        const SizedBox(height: 16),
        VenueLocationCard(booking: booking),
        const SizedBox(height: 16),
        PaymentHistoryCard(),
        const SizedBox(height: 16),
        ActivityTimelineCard(activities: activities),
      ],
    );
  }

  Widget _buildTabletLayout(
    AdminBookingUIModel booking,
    List<VendorModel> vendors,
    List<ActivityModel> activities,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              BookingSummaryCard(booking: booking),
              const SizedBox(height: 16),
              CustomerDetailsCard(booking: booking),
              const SizedBox(height: 16),
              EventInfoCard(booking: booking),
              const SizedBox(height: 16),
              VenueLocationCard(booking: booking),
              const SizedBox(height: 16),
              PaymentHistoryCard(),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              StatusCard(booking: booking),
              const SizedBox(height: 16),
              VendorSection(vendors: vendors, booking: booking),
              const SizedBox(height: 16),
              ActivityTimelineCard(activities: activities),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    AdminBookingUIModel booking,
    List<VendorModel> vendors,
    List<ActivityModel> activities,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: BookingSummaryCard(booking: booking)),
                  const SizedBox(width: 16),
                  Expanded(child: CustomerDetailsCard(booking: booking)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: EventInfoCard(booking: booking)),
                  const SizedBox(width: 16),
                  Expanded(child: VenueLocationCard(booking: booking)),
                ],
              ),
              const SizedBox(height: 16),
              PaymentHistoryCard(),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              StatusCard(booking: booking),
              const SizedBox(height: 16),
              VendorSection(vendors: vendors, booking: booking),
              const SizedBox(height: 16),
              ActivityTimelineCard(activities: activities),
            ],
          ),
        ),
      ],
    );
  }

  List<VendorModel> _getVendorsFromEntity(AdminBookingDetailEntity entity) {
    if (entity.assignedVendors.isNotEmpty) {
      return entity.assignedVendors.map((v) => VendorModel(
        id: v['id'] ?? '',
        name: v['name'] ?? 'Unknown',
        category: 'Assigned Vendor',
        status: 'Active',
      )).toList();
    }
    
    // Fallback for single vendor if list is empty (for backward compatibility)
    if (entity.vendorName != 'Not Assigned') {
      return [
        VendorModel(
          id: entity.vendorId ?? '',
          name: entity.vendorName,
          category: 'Assigned Vendor',
          status: 'Active',
        ),
      ];
    }
    return [];
  }

  List<ActivityModel> _getActivitiesFromEntity(dynamic entity) {
    // API doesn't provide timeline yet, returning initial creation activity
    return [
      ActivityModel(
        title: 'Booking Created',
        subtitle: 'Initial booking request submitted.',
        timestamp: DateTime.tryParse(entity.createdAt) ?? DateTime.now(),
        icon: Icons.add_business_outlined,
      ),
    ];
  }
}

class BookingDetailSkeleton extends StatelessWidget {
  const BookingDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoadingSkeleton(height: 40, width: 300),
        SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: LoadingSkeleton(height: 150)),
            SizedBox(width: 16),
            Expanded(child: LoadingSkeleton(height: 150)),
          ],
        ),
        SizedBox(height: 16),
        LoadingSkeleton(height: 200),
        SizedBox(height: 16),
        LoadingSkeleton(height: 150),
      ],
    );
  }
}
