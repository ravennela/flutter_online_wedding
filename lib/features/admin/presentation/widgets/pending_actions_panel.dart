import 'package:flutter/material.dart';
import '../../dashboard/domain/entities/admin_dashboard_entity.dart';

class PendingActionsPanel extends StatelessWidget {
  final AdminPendingActionsEntity pendingActions;
  const PendingActionsPanel({super.key, required this.pendingActions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange.shade800, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Pending Actions",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1F36)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ActionItem(
            icon: Icons.person_add_alt,
            title: "Vendor Assignment",
            desc: "${pendingActions.vendorAssignmentCount} events marked pending",
            action: "Assign",
          ),
          const SizedBox(height: 16),
          _ActionItem(
            icon: Icons.payments_outlined,
            title: "Payment Review",
            desc: "${pendingActions.paymentReviewCount} new proofs uploaded",
            action: "Review",
          ),
          const SizedBox(height: 16),
          _ActionItem(
            icon: Icons.chat_bubble_outline,
            title: "New Inquiries",
            desc: "0 unread messages",
            action: "View",
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final String action;

  const _ActionItem({required this.icon, required this.title, required this.desc, required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F3), // Light orange tint
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.orange.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange.shade900)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 11, color: Colors.orange.shade800)),
              ],
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                action.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
