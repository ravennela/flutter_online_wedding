import 'package:flutter/material.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/kpi_card.dart';
import '../widgets/analytics_section.dart';
import '../widgets/recent_bookings_table.dart';
import '../widgets/upcoming_events_section.dart';
import '../widgets/pending_actions_panel.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Dashboard',
      selectedIndex: 0,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 1000;
          final padding = isMobile ? 16.0 : 32.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile) ...[
                   const _DashboardHeader(),
                   const SizedBox(height: 32),
                ],
                KpiSection(isMobile: isMobile),
                const SizedBox(height: 32),
                const AnalyticsSection(),
                const SizedBox(height: 32),
                const RecentBookingsTable(),
                const SizedBox(height: 32),
                if (isMobile) ...[
                  const UpcomingEventsSection(),
                  const SizedBox(height: 32),
                  const PendingActionsPanel(),
                ] else ...[
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: UpcomingEventsSection()),
                      SizedBox(width: 32),
                      Expanded(flex: 1, child: PendingActionsPanel()),
                    ],
                  ),
                ],
                const SizedBox(height: 48),
                Center(
                  child: Text(
                    "© 2025 Event Management Platform Admin",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
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
  const KpiSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return const Column(
        children: [
           KpiCard(title: "Total Bookings", value: "1,240", change: "12% increase", isPositive: true),
           SizedBox(height: 16),
           KpiCard(title: "Today's Events", value: "8", change: "+2 new", isPositive: true),
           SizedBox(height: 16),
           KpiCard(title: "Monthly Revenue", value: "\$45.2k", change: "8.4% growth", isPositive: true),
           SizedBox(height: 16),
           KpiCard(title: "Pending Actions", value: "12", change: "1 Urgent", isPositive: false, isUrgent: true),
        ],
      );
    }
    return const Row(
      children: [
        Expanded(child: KpiCard(title: "Total Bookings", value: "1,240", change: "12% increase", isPositive: true)),
        SizedBox(width: 24),
        Expanded(child: KpiCard(title: "Today's Events", value: "8", change: "+2 new", isPositive: true)),
        SizedBox(width: 24),
        Expanded(child: KpiCard(title: "Monthly Revenue", value: "\$45.2k", change: "8.4% growth", isPositive: true)),
        SizedBox(width: 24),
        Expanded(child: KpiCard(title: "Pending Actions", value: "12", change: "1 Urgent", isPositive: false, isUrgent: true)),
      ],
    );
  }
}
