import 'package:flutter/material.dart';
import 'package:flutter_online/features/admin/bookings/domain/entities/admin_booking_entity.dart';

import 'status_badge.dart';
import 'booking_action_menu.dart';
import 'package:intl/intl.dart';

class BookingTable extends StatelessWidget {
  final List<AdminBookingEntity> bookings;

  const BookingTable({
    super.key,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          dataRowHeight: 70,
          horizontalMargin: 24,
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('Booking ID')),
            DataColumn(label: Text('User')),
            DataColumn(label: Text('Event')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('City')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Payment')),
            DataColumn(label: Text('Actions')),
          ],
          rows: bookings.map((booking) => _buildDataRow(context, booking)).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, AdminBookingEntity booking) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    DateTime? eventDate;
    try {
      eventDate = DateTime.parse(booking.eventDate);
    } catch (_) {}

    return DataRow(
      cells: [
        DataCell(Text('#${booking.bookingId.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.userName ?? 'System User', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('ID: ${booking.bookingId.substring(0, 8)}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
        ),
        DataCell(Text(booking.eventType)),
        DataCell(Text(eventDate != null ? dateFormat.format(eventDate) : booking.eventDate)),
        DataCell(Text(booking.city)),
        DataCell(Text(currencyFormat.format(booking.totalAmount), style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(_getStatusBadge(booking.status)),
        DataCell(_getPaymentBadge(booking.paymentStatus)),
        DataCell(BookingActionMenu(booking: booking)),
      ],
    );
  }

  Widget _getStatusBadge(String status) {
    final s = status.toUpperCase();
    if (s == 'REQUESTED') return const StatusBadge(label: 'Requested', color: Colors.orange);
    if (s == 'APPROVED') return const StatusBadge(label: 'Approved', color: Colors.blue);
    if (s == 'CONFIRMED') return const StatusBadge(label: 'Confirmed', color: Colors.green);
    if (s == 'CANCELLED') return const StatusBadge(label: 'Cancelled', color: Colors.red);
    return StatusBadge(label: status, color: Colors.grey);
  }

  Widget _getPaymentBadge(String status) {
    final s = status.toUpperCase();
    if (s == 'PENDING') return const StatusBadge(label: 'Pending', color: Colors.grey);
    if (s == 'INITIATED') return const StatusBadge(label: 'Initiated', color: Colors.orange);
    if (s == 'SUCCESS') return const StatusBadge(label: 'Success', color: Colors.green);
    if (s == 'FAILED') return const StatusBadge(label: 'Failed', color: Colors.red);
    if (s == 'REFUNDED') return const StatusBadge(label: 'Refunded', color: Colors.purple);
    return StatusBadge(label: status, color: Colors.grey);
  }
}
