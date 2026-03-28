import 'package:flutter/material.dart';
import '../../dashboard/domain/entities/admin_dashboard_entity.dart';


class RecentBookingsTable extends StatelessWidget {
  final List<AdminRecentBookingEntity> bookings;
  const RecentBookingsTable({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FixedColumnWidth(120),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FixedColumnWidth(140),
                  4: FixedColumnWidth(140),
                },
                children: [
                  _headerRow(),
                  ...bookings.map((booking) => _dataRow(
                        booking.bookingId ?? 'N/A',
                        booking.customerName,
                        booking.eventType,
                        booking.status,
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  TableRow _headerRow() {
    return const TableRow(
      children: [
        _HeaderCell("Booking ID"),
        _HeaderCell("Customer"),
        _HeaderCell("Event Type"),
        _HeaderCell("Status"),
        _HeaderCell("Actions"),
      ],
    );
  }

  TableRow _dataRow(
    String id,
    String customer,
    String event,
    String status,
  ) {
    return TableRow(
      children: [
        _TextCell(id),
        _TextCell(customer),
        _TextCell(event),
        _StatusCell(status),
        _ActionCell(),
      ],
    );
  }
}

/* ---------------- CELLS ---------------- */

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1F36),
          fontSize: 13,
        ),
      ),
    );
  }
}

class _TextCell extends StatelessWidget {
  final String text;
  const _TextCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 13,
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
    final isActive = status == "Active";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? Colors.green.shade200 : Colors.grey.shade300,
            ),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 18),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
