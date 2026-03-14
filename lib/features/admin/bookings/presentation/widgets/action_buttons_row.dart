import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/admin/bookings/models/admin_booking_ui_model.dart';
import 'package:flutter_online/features/admin/bookings/models/vendor_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_online/core/routes/app_routes.dart';

import '../bloc/admin_booking_detail_bloc.dart';
import '../utils/booking_status_helper.dart';

class ActionButtonsRow extends StatelessWidget {
  final AdminBookingUIModel booking;

  const ActionButtonsRow({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final isCancelled = booking.isCancelled;
    final isRefundable = booking.isRefundable;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionButton(
          context,
          'Update Status',
          Icons.edit_calendar_outlined,
          Colors.indigo,
          onPressed: isCancelled ? null : () => _showStatusDialog(context),
        ),
        _buildActionButton(
          context,
          'Assign Vendor',
          Icons.person_add_outlined,
          Colors.blue,
          onPressed: isCancelled ? null : () {
            context.push(
              AppRoutes.adminSelectVendor,
              extra: SelectVendorArgs(
                bookingId: booking.id,
                bookingCode: booking.bookingCode,
                eventCategory: booking.eventType,
                city: booking.city,
              ),
            );
          },
        ),
        _buildActionButton(
          context,
          'Cancel Booking',
          Icons.cancel_outlined,
          Colors.red,
          isOutlined: true,
          onPressed: isCancelled ? null : () => _showCancelDialog(context),
        ),
        _buildActionButton(
          context,
          'Process Refund',
          Icons.replay_outlined,
          Colors.orange,
          onPressed: isRefundable ? () {} : null,
        ),
      ],
    );
  }

  void _showStatusDialog(BuildContext context) {
    BookingStatusHelper.showStatusDialog(
      context: context,
      currentStatus: booking.status,
      onStatusSelected: (status) {
        if (status.toUpperCase() == 'CANCELLED') {
          _showCancelDialog(context);
        } else {
          _updateStatus(context, status);
        }
      },
    );
  }

  void _updateStatus(BuildContext context, String status) {
    context.read<AdminBookingDetailBloc>().add(UpdateBookingStatus(booking.id, status));
  }

  void _showCancelDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
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
              child: const Text('Discard'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final reason = reasonController.text.trim();
                  Navigator.pop(dialogContext);
                  _cancelBooking(context, reason);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _cancelBooking(BuildContext context, String reason) {
    context.read<AdminBookingDetailBloc>().add(AdminCancelBooking(booking.id, reason));
  }

  Widget _buildActionButton(
    BuildContext context, 
    String label, 
    IconData icon, 
    Color color, 
    {VoidCallback? onPressed, bool isOutlined = false}
  ) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}
