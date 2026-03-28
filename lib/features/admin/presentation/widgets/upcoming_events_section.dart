import 'package:flutter/material.dart';
import '../../dashboard/domain/entities/admin_dashboard_entity.dart';

class UpcomingEventsSection extends StatelessWidget {
  final List<AdminUpcomingEventEntity> events;
  const UpcomingEventsSection({super.key, required this.events});

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
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F36)),
          ),
          const SizedBox(height: 24),
          if (events.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No upcoming events"),
              ),
            )
          else
            ...events.map((event) => Column(
                  children: [
                    _EventItem(
                      name: event.title,
                      date: "${event.date}${event.time != null ? ' • ${event.time}' : ''}",
                      vendor: event.vendorName,
                      status: event.status,
                    ),
                    const SizedBox(height: 16),
                  ],
                )),
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
