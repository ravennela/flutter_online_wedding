import 'package:flutter/material.dart';
import '../../models/admin_booking_ui_model.dart';
import 'status_badge.dart';

class StatusCard extends StatelessWidget {
  final AdminBookingUIModel booking;

  const StatusCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String description;
    
    switch (booking.status.toUpperCase()) {
      case 'CONFIRMED':
        statusColor = Colors.green;
        description = 'This booking is confirmed. All logistics and vendors are being coordinated as per the schedule.';
        break;
      case 'REQUESTED':
        statusColor = Colors.orange;
        description = 'This is a preliminary request. Please review the details and confirm with the customer.';
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        description = 'This booking has been cancelled. No further actions are required unless a refund is needed.';
        break;
      default:
        statusColor = Colors.grey;
        description = 'Booking is currently in ${booking.status} state.';
    }

    return Card(
      elevation: 0,
      color: statusColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            StatusBadge(
              label: booking.status,
              color: statusColor,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('View Digital Contract'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: statusColor.withOpacity(0.5)),
                  foregroundColor: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
