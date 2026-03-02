import 'package:flutter/material.dart';
import 'package:flutter_online/features/admin/bookings/domain/entities/admin_booking_entity.dart';


class BookingActionMenu extends StatelessWidget {
  final AdminBookingEntity booking;

  const BookingActionMenu({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = booking.status.toUpperCase() == 'CANCELLED';
    final isSuccessPayment = booking.paymentStatus.toUpperCase() == 'SUCCESS';

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => _handleAction(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: ListTile(
            leading: Icon(Icons.visibility),
            title: Text('View Details'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        PopupMenuItem(
          value: 'status',
          enabled: !isCancelled,
          child: const ListTile(
            leading: Icon(Icons.edit_calendar),
            title: Text('Update Status'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        PopupMenuItem(
          value: 'vendor',
          enabled: !isCancelled,
          child: const ListTile(
            leading: Icon(Icons.person_add),
            title: Text('Assign Vendor'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'cancel',
          enabled: !isCancelled,
          child: ListTile(
            leading: Icon(Icons.cancel, color: !isCancelled ? Colors.red : Colors.grey),
            title: Text('Cancel Booking', style: TextStyle(color: !isCancelled ? Colors.red : Colors.grey)),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        if (isSuccessPayment)
          PopupMenuItem(
            value: 'refund',
            enabled: !isCancelled,
            child: const ListTile(
              leading: Icon(Icons.replay),
              title: Text('Process Refund'),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
      ],
    );
  }

  void _handleAction(BuildContext context, String action) {
    final displayId = booking.bookingId.substring(0, 8).toUpperCase();
    switch (action) {
      case 'view':
        // Navigator.pushNamed(context, '/admin/bookings/details');
        break;
      case 'cancel':
        _showCancelConfirmation(context);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action "$action" triggered for #$displayId')),
        );
    }
  }

  void _showCancelConfirmation(BuildContext context) {
    final displayId = booking.bookingId.substring(0, 8).toUpperCase();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel booking #$displayId? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );
  }
}
