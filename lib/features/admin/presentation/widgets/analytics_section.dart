import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../dashboard/domain/entities/admin_dashboard_entity.dart';

class AnalyticsSection extends StatelessWidget {
  final List<BookingOverviewEntity> overview;
  final AdminBookingStatusEntity status;

  const AnalyticsSection({
    super.key,
    required this.overview,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _BookingOverviewChart(overview: overview),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _BookingStatusChart(status: status),
        ),
      ],
    );
  }
}

class _BookingOverviewChart extends StatelessWidget {
  final List<BookingOverviewEntity> overview;

  const _BookingOverviewChart({required this.overview});

  @override
  Widget build(BuildContext context) {
    final maxCount = overview.isEmpty
        ? 1
        : overview
            .map((e) => e.count)
            .reduce((value, element) => value > element ? value : element);

    return Container(
      padding: const EdgeInsets.all(24),
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Booking Overview",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1F36)),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: "This Week",
                  items: const [
                    DropdownMenuItem(
                        value: "This Week", child: Text("This Week")),
                    DropdownMenuItem(
                        value: "Last Week", child: Text("Last Week")),
                  ],
                  onChanged: (v) {},
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: overview.isEmpty
                ? const Center(child: Text("No data available"))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: overview.map((item) {
                      return _BarColumn(
                        label: item.day.length > 3
                            ? item.day.substring(0, 3)
                            : item.day,
                        heightPkg: item.count / (maxCount == 0 ? 1 : maxCount),
                        count: item.count,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  final String label;
  final double heightPkg;
  final int count;
  final bool isActive;

  const _BarColumn({
    required this.label,
    required this.heightPkg,
    required this.count,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: "$count bookings",
          child: Container(
            width: 30,
            height: (180 * heightPkg).clamp(5.0, 180.0),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue.shade700 : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _BookingStatusChart extends StatelessWidget {
  final AdminBookingStatusEntity status;

  const _BookingStatusChart({required this.status});

  @override
  Widget build(BuildContext context) {
    final total = status.confirmed + status.pending + status.cancelled;
    final successRate = total == 0 ? 0 : (status.confirmed / total * 100).round();

    return Container(
      padding: const EdgeInsets.all(24),
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Booking Status",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F36)),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    confirmed: status.confirmed.toDouble(),
                    pending: status.pending.toDouble(),
                    cancelled: status.cancelled.toDouble(),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$successRate%",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1F36)),
                        ),
                        const Text(
                          "Success",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          _LegendItem(
              color: Colors.blue.shade700,
              label: "Confirmed",
              value: status.confirmed.toString()),
          const SizedBox(height: 8),
          _LegendItem(
              color: Colors.orange.shade300,
              label: "Pending",
              value: status.pending.toString()),
          const SizedBox(height: 8),
          _LegendItem(
              color: Colors.red.shade300,
              label: "Canceled",
              value: status.cancelled.toString()),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem(
      {required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F36))),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double confirmed;
  final double pending;
  final double cancelled;

  _DonutChartPainter({
    required this.confirmed,
    required this.pending,
    required this.cancelled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = confirmed + pending + cancelled;
    if (total == 0) {
      final paint = Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20.0;
      canvas.drawCircle(Offset(size.width / 2, size.height / 2),
          size.width / 2 - 10, paint);
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 20.0;

    final rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paintConfirmed = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintPending = Paint()
      ..color = Colors.orange.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintCancelled = Paint()
      ..color = Colors.red.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    const gap = 0.1;

    double currentAngle = startAngle;

    final confirmedSweep = (confirmed / total) * (2 * math.pi) - (confirmed > 0 && (pending > 0 || cancelled > 0) ? gap : 0);
    if (confirmed > 0) {
      canvas.drawArc(rect, currentAngle, confirmedSweep, false, paintConfirmed);
      currentAngle += confirmedSweep + (confirmed > 0 && (pending > 0 || cancelled > 0) ? gap : 0);
    }

    final pendingSweep = (pending / total) * (2 * math.pi) - (pending > 0 && (cancelled > 0 || confirmed > 0) ? gap : 0);
    if (pending > 0) {
      canvas.drawArc(rect, currentAngle, pendingSweep, false, paintPending);
       currentAngle += pendingSweep + (pending > 0 && (cancelled > 0 || confirmed > 0) ? gap : 0);
    }

    final cancelledSweep = (cancelled / total) * (2 * math.pi) - (cancelled > 0 && (confirmed > 0 || pending > 0) ? gap : 0);
    if (cancelled > 0) {
      canvas.drawArc(rect, currentAngle, cancelledSweep, false, paintCancelled);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
