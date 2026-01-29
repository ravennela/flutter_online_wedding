import 'package:flutter/material.dart';

class RecentBookingsTable extends StatelessWidget {
  const RecentBookingsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Bookings",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("View All Bookings"),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          // Table
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
               0: FlexColumnWidth(1.2), // ID
               1: FlexColumnWidth(2), // Customer
               2: FlexColumnWidth(1.5), // Type
               3: FlexColumnWidth(1.5), // Date
               4: FlexColumnWidth(1.2), // Amount
               5: FlexColumnWidth(1.2), // Status
               6: FixedColumnWidth(80), // Action
            },
            children: [
              // Header Row
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF9FAFB)),
                children: [
                  _HeaderCell("Booking ID", isFirst: true),
                  _HeaderCell("Customer Name"),
                  _HeaderCell("Event Type"),
                  _HeaderCell("Date"),
                  _HeaderCell("Amount"),
                  _HeaderCell("Status"),
                  _HeaderCell("Action", align: TextAlign.end, isLast: true),
                ],
              ),
              // Filtered Rows
              ..._generateRows(),
            ],
          ),
          
          // Pagination
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                 Text("Showing 1-5 of 60", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                 const Spacer(),
                Text("Page 1 of 12", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.chevron_left, size: 16, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                   decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.chevron_right, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<TableRow> _generateRows() {
    final data = [
      ["#BK-7829", "Sarah Williams", "Wedding", "Oct 24, 2025", "\$12,500", "Confirmed"],
      ["#BK-7830", "Michael Chen", "Corporate", "Oct 26, 2025", "\$8,200", "Pending"],
      ["#BK-7831", "Emily Davis", "Birthday", "Oct 28, 2025", "\$3,400", "Confirmed"],
      ["#BK-7832", "James Wilson", "Launch", "Nov 02, 2025", "\$15,000", "Processing"],
      ["#BK-7833", "Linda Martinez", "Anniversary", "Nov 05, 2025", "\$4,100", "Confirmed"],
    ];

    return data.map((row) {
      return TableRow(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        children: [
          _DataCell(row[0], isId: true),
          _DataCell(row[1], isBold: true),
          _DataCell(row[2]),
          _DataCell(row[3]),
          _DataCell(row[4]),
          _StatusCell(row[5]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {},
                  child: Icon(Icons.visibility_outlined, color: Colors.grey.shade400, size: 20)
                )),
          ),
        ],
      );
    }).toList();
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final TextAlign align;
  final bool isFirst;
  final bool isLast;

  const _HeaderCell(this.text, {this.align = TextAlign.start, this.isFirst = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isFirst ? 24 : 16, 
        right: isLast ? 24 : 16, 
        top: 16, 
        bottom: 16
      ),
      child: Text(
        text.toUpperCase(),
        textAlign: align,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final bool isId;
  final bool isBold;

  const _DataCell(this.text, {this.isId = false, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0), // Align with header
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: isId ? Colors.blue.shade700 : const Color(0xFF1A1F36),
            ),
          ),
        ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  final String status;

  const _StatusCell(this.status);

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    switch (status) {
      case "Confirmed":
        bg = Colors.green.shade50;
        text = Colors.green.shade700;
        break;
      case "Pending":
        bg = Colors.orange.shade50;
        text = Colors.orange.shade700;
        break;
      case "Processing":
        bg = Colors.blue.shade50;
        text = Colors.blue.shade700;
        break;
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade700;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: text),
            ),
          ),
        ],
      ),
    );
  }
}
