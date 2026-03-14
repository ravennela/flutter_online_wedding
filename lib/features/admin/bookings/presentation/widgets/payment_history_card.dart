import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'status_badge.dart';

class PaymentHistoryCard extends StatelessWidget {
  const PaymentHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTransactionItem(
              'TXN-90122',
              DateTime.now().subtract(const Duration(days: 2)),
              'Credit Card',
              2500.00,
              'SUCCESS',
              Colors.green,
            ),
            const Divider(height: 32),
            _buildTransactionItem(
              'TXN-89211',
              DateTime.now().subtract(const Duration(days: 15)),
              'Bank Transfer',
              1500.00,
              'SUCCESS',
              Colors.green,
            ),
            const Divider(height: 32),
            _buildTransactionItem(
              'TXN-88102',
              DateTime.now().subtract(const Duration(days: 30)),
              'Wallet',
              500.00,
              'FAILED',
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String id, 
    DateTime date, 
    String method, 
    double amount, 
    String status,
    Color statusColor,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.receipt_long_outlined, color: Colors.grey.shade600, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('${dateFormat.format(date)} • $method', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(currencyFormat.format(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            StatusBadge(label: status, color: statusColor),
          ],
        ),
      ],
    );
  }
}
