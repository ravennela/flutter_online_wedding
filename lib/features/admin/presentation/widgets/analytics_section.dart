import 'package:flutter/material.dart';

class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _BookingOverviewChart(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _BookingStatusChart(),
        ),
      ],
    );
  }
}

class _BookingOverviewChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: "This Week",
                  items: const [
                    DropdownMenuItem(value: "This Week", child: Text("This Week")),
                    DropdownMenuItem(value: "Last Week", child: Text("Last Week")),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _BarColumn(label: "Mon", heightPkg: 0.4),
                _BarColumn(label: "Tue", heightPkg: 0.6),
                _BarColumn(label: "Wed", heightPkg: 0.3),
                _BarColumn(label: "Thu", heightPkg: 0.8, isActive: true),
                _BarColumn(label: "Fri", heightPkg: 0.5),
                _BarColumn(label: "Sat", heightPkg: 0.7),
                _BarColumn(label: "Sun", heightPkg: 0.4),
              ],
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
  final bool isActive;

  const _BarColumn({required this.label, required this.heightPkg, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        
        Container(
          width: 30,
          height: 180 * heightPkg,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.shade700 : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(6),
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
  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(
                  painter: _DonutChartPainter(),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "85%",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
                        ),
                        Text(
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
          _LegendItem(color: Colors.blue.shade700, label: "Confirmed", value: "1,054"),
          const SizedBox(height: 8),
          _LegendItem(color: Colors.orange.shade300, label: "Pending", value: "142"),
          const SizedBox(height: 8),
          _LegendItem(color: Colors.red.shade300, label: "Canceled", value: "44"),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({required this.color, required this.label, required this.value});

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
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36))),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 20.0;
    
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paint1 = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paint2 = Paint()
      ..color = Colors.orange.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paint3 = Paint()
      ..color = Colors.red.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arcs
    
    const startAngle = -1.5708; // -90 deg
    const sweep1 = 4.8; // ~85%
    const gap = 0.1;
    
    canvas.drawArc(rect, startAngle, sweep1, false, paint1);
    
    canvas.drawArc(rect, startAngle + sweep1 + gap, 0.8, false, paint2);

    canvas.drawArc(rect, startAngle + sweep1 + gap + 0.8 + gap, 0.3, false, paint3);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
