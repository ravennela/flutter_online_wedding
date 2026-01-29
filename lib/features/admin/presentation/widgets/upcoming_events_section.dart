import 'package:flutter/material.dart';

class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Events",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
          ),
          const SizedBox(height: 24),
          _EventItem(
            name: "Johnson Wedding Reception",
            date: "Oct 24, 2025 • 2:00 PM",
            vendor: "Floral Dreams Co.",
            status: "Ready",
          ),
          const SizedBox(height: 16),
          _EventItem(
            name: "Tech Corp Annual Gala",
            date: "Oct 26, 2025 • 6:00 PM",
            vendor: "Elite Catering",
            status: "Prep",
          ),
          const SizedBox(height: 16),
          _EventItem(
            name: "Sarah's 30th Birthday",
            date: "Oct 28, 2025 • 7:00 PM",
            vendor: "Party Makers",
            status: "Ready",
          ),
          const SizedBox(height: 16),
           _EventItem(
            name: "Global Summit 2025",
            date: "Nov 02, 2025 • 9:00 AM",
            vendor: "Convention Pros",
            status: "Prep",
          ),
        ],
      ),
    );
  }
}

class _EventItem extends StatelessWidget {
  final String name;
  final String date;
  final String vendor;
  final String status;

  const _EventItem({
    required this.name,
    required this.date,
    required this.vendor,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.event_available, color: Colors.blue.shade700, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name, 
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(vendor, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: status == "Ready" ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: status == "Ready" ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
