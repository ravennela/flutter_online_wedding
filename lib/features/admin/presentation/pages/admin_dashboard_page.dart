import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:intl/intl.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/kpi_card.dart';
import '../widgets/analytics_section.dart';
import '../widgets/recent_bookings_table.dart';
import '../widgets/upcoming_events_section.dart';
import '../widgets/pending_actions_panel.dart';
import '../../dashboard/presentation/bloc/admin_dashboard_bloc.dart';
import '../../dashboard/presentation/bloc/admin_dashboard_event_state.dart';
import '../../dashboard/domain/entities/admin_dashboard_entity.dart';


class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<AdminDashboardBloc>()..add(FetchAdminDashboardData()),
      child: AdminScaffold(
        title: 'Dashboard',
        selectedIndex: 0,
        body: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
          builder: (context, state) {
            if (state is AdminDashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminDashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: ${state.message}"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<AdminDashboardBloc>()
                          .add(FetchAdminDashboardData()),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            if (state is AdminDashboardLoaded) {
              final data = state.dashboardData;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 1000;
                  final padding = isMobile ? 16.0 : 32.0;

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<AdminDashboardBloc>()
                          .add(FetchAdminDashboardData());
                    },
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(padding),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMobile) ...[
                            const _DashboardHeader(),
                            const SizedBox(height: 32),
                          ],
                          KpiSection(isMobile: isMobile, stats: data.stats),
                          const SizedBox(height: 32),
                          AnalyticsSection(
                            overview: data.bookingOverview,
                            status: data.bookingStatus,
                          ),
                          const SizedBox(height: 32),
                          RecentBookingsTable(bookings: data.recentBookings),
                          const SizedBox(height: 32),
                          if (isMobile) ...[
                            UpcomingEventsSection(events: data.upcomingEvents),
                            const SizedBox(height: 32),
                            PendingActionsPanel(
                                pendingActions: data.pendingActions),
                          ] else ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: UpcomingEventsSection(
                                        events: data.upcomingEvents)),
                                const SizedBox(width: 32),
                                Expanded(
                                    flex: 1,
                                    child: PendingActionsPanel(
                                        pendingActions: data.pendingActions)),
                              ],
                            ),
                          ],
                          const SizedBox(height: 48),
                          Center(
                            child: Text(
                              "© 2026 Event Management Platform Admin",
                              style: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dashboard Overview",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1F36),
              ),
        ),
        const SizedBox(height: 8),
        Text(
          "Welcome back, Administrator. Here's what's happening today.",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }
}

class KpiSection extends StatelessWidget {
  final bool isMobile;
  final AdminStatsEntity stats;
  const KpiSection({super.key, required this.isMobile, required this.stats});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.compactCurrency(symbol: '₹');
    final numberFormat = NumberFormat.compact();

    final cards = [
      KpiCard(
          title: "Total Bookings",
          value: numberFormat.format(stats.totalBookings),
          change: "Total tracked",
          isPositive: true),
      KpiCard(
          title: "Today's Events",
          value: stats.todayEvents.toString(),
          change: "Happening now",
          isPositive: true),
      KpiCard(
          title: "Monthly Revenue",
          value: currencyFormat.format(stats.monthlyRevenue),
          change: "Current month",
          isPositive: true),
      KpiCard(
          title: "Pending Actions",
          value: stats.pendingActions.toString(),
          change: stats.pendingActions > 0 ? "Needs attention" : "All caught up",
          isPositive: stats.pendingActions == 0,
          isUrgent: stats.pendingActions > 0),
    ];

    if (isMobile) {
      return Column(
        children: cards
            .expand((card) => [card, const SizedBox(height: 16)])
            .toList()
          ..removeLast(),
      );
    }
    return Row(
      children: cards
          .expand((card) => [Expanded(child: card), const SizedBox(width: 24)])
          .toList()
        ..removeLast(),
    );
  }
}
