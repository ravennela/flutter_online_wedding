import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_online/features/admin/bookings/domain/entities/admin_booking_entity.dart';
import 'package:flutter_online/features/admin/bookings/models/vendor_model.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import '../bloc/admin_bookings_bloc.dart';
import '../utils/booking_status_helper.dart';

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
    switch (action) {
      case 'view':
        context.push(
          AppRoutes.adminBookingDetail,
          extra: booking.bookingId,
        );
        break;
      case 'status':
        _showStatusDialog(context);
        break;
      case 'vendor':
        context.push(
          AppRoutes.adminSelectVendor,
          extra: SelectVendorArgs(
            bookingId: booking.bookingId,
            bookingCode: booking.bookingId.substring(0, 8).toUpperCase(),
            eventCategory: booking.eventType,
            city: booking.city,
          ),
        );
        break;
      case 'cancel':
        _showCancelDialog(context);
        break;
      default:
        final displayId = booking.bookingId.substring(0, 8).toUpperCase();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action "$action" triggered for #$displayId')),
        );
    }
  }

  void _showStatusDialog(BuildContext context) {
    BookingStatusHelper.showStatusDialog(
      context: context,
      currentStatus: booking.status,
      onStatusSelected: (status) {
        if (status.toUpperCase() == 'CANCELLED') {
          _showCancelDialog(context);
        } else {
          context.read<AdminBookingsBloc>().add(UpdateBookingStatusInList(booking.bookingId, status));
        }
      },
    );
  }

  void _showCancelDialog(BuildContext context) {
    final displayId = booking.bookingId.substring(0, 8).toUpperCase();
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Cancel Booking #$displayId'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to cancel this booking? This action cannot be undone.'),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Cancellation Reason',
                  hintText: 'Enter reason for cancellation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reason for cancellation';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final reason = reasonController.text.trim();
                Navigator.pop(dialogContext);
                context.read<AdminBookingsBloc>().add(AdminCancelBookingInList(booking.bookingId, reason));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );
  }
}
