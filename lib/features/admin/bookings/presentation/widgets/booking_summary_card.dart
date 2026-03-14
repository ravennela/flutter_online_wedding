import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/admin_booking_ui_model.dart';

class BookingSummaryCard extends StatelessWidget {
  final AdminBookingUIModel booking;

  const BookingSummaryCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildAmountRow('Total Amount', booking.totalAmount, Colors.black),
            const Divider(height: 24),
            _buildAmountRow('Paid Amount', booking.paidAmount, Colors.green),
            const Divider(height: 24),
            _buildAmountRow('Due Balance', booking.dueBalance, 
                booking.dueBalance > 0 ? Colors.red : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, Color amountColor) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
