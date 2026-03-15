import 'package:flutter/material.dart';

class BookingStatusHelper {
  static List<String> getAvailableTransitions(String current) {
    switch (current.toUpperCase()) {
      case 'REQUESTED':
        return [ 'CANCELLED'];
      case 'VENDOR_ASSIGNED':
        return ['CONFIRMED', 'CANCELLED'];
      case 'CONFIRMED':
        return ['IN_PROGRESS', 'CANCELLED'];
      case 'IN_PROGRESS':
        return ['COMPLETED', 'CANCELLED'];
      default:
        return [];
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'REQUESTED': return Icons.pending_actions;
      case 'APPROVED': return Icons.check_circle_outline;
      case 'VENDOR_ASSIGNED': return Icons.person_pin_outlined;
      case 'CONFIRMED': return Icons.verified_outlined;
      case 'IN_PROGRESS': return Icons.sync;
      case 'COMPLETED': return Icons.task_alt;
      case 'CANCELLED': return Icons.cancel_outlined;
      default: return Icons.help_outline;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'REQUESTED': return Colors.orange;
      case 'APPROVED': return Colors.green;
      case 'VENDOR_ASSIGNED': return Colors.blue;
      case 'CONFIRMED': return Colors.teal;
      case 'IN_PROGRESS': return Colors.amber;
      case 'COMPLETED': return Colors.indigo;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }

  static void showStatusDialog({
    required BuildContext context,
    required String currentStatus,
    required Function(String) onStatusSelected,
  }) {
    final availableStatuses = getAvailableTransitions(currentStatus);

    if (availableStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No further status transitions available.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Booking Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableStatuses.map((status) {
            return ListTile(
              title: Text(status.replaceAll('_', ' ')),
              leading: Icon(getStatusIcon(status), color: getStatusColor(status)),
              onTap: () {
                Navigator.pop(dialogContext);
                onStatusSelected(status);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
