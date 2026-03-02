import 'package:flutter/material.dart';
import 'package:flutter_online/features/admin/bookings/domain/entities/admin_booking_entity.dart';

import 'status_badge.dart';
import 'booking_action_menu.dart';
import 'package:intl/intl.dart';

class BookingCard extends StatelessWidget {
  final AdminBookingEntity booking;

  const BookingCard({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    DateTime? eventDate;
    try {
      eventDate = DateTime.parse(booking.eventDate);
    } catch (_) {}

    final isCancelled = booking.status.toUpperCase() == 'CANCELLED';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCancelled ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: isCancelled ? 0.6 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${booking.bookingId.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.userName ?? 'System User',
                      style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                BookingActionMenu(booking: booking),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Event', booking.eventType, Icons.event),
                ),
                Expanded(
                  child: _buildInfoItem('Date', eventDate != null ? dateFormat.format(eventDate) : booking.eventDate, Icons.calendar_today),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Location', booking.city, Icons.location_on),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(booking.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _getStatusBadge(booking.status),
                _getPaymentBadge(booking.paymentStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
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
