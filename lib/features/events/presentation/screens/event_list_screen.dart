import 'package:flutter/material.dart';
import 'package:flutter_online/features/events/domain/models/event_type.dart';
import 'package:flutter_online/features/events/presentation/widgets/CategoryFilterBar.dart';
import 'package:flutter_online/features/events/presentation/widgets/SectionHeader.dart';
import 'package:flutter_online/features/events/presentation/widgets/event_card.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final List<EventType> mockEvents = [
      EventType(
        id: '1',
        name: "Ananya's Saree Function",
        dateText: 'Oct 24 • 6:00 PM',
        imageUrl:
            'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?auto=format&fit=crop&w=900&q=80', categoryTag: 'Traditional',
      ),
      EventType(
        id: '2',
        name: "Vikram's Golden Jubilee",
        dateText: 'Nov 12 • 7:30 PM',
        imageUrl:
            'https://images.unsplash.com/photo-1604014237800-1c9102c219da?auto=format&fit=crop&w=900&q=80', categoryTag: 'Birthday',
      ),
      EventType(
        id: '3',
        name: "The Mehra's Silver Gala",
        dateText: 'Dec 05 • 8:00 PM',
        imageUrl:
            'https://images.unsplash.com/photo-1529634891934-2d1dc06c1d9c?auto=format&fit=crop&w=900&q=80', categoryTag: 'Anniversary',
      ),
      EventType(
        id: '4',
        name: "Rohan's Upanayana",
        dateText: 'Jan 10 • 10:30 AM',
        imageUrl:
            'https://images.unsplash.com/photo-1594631661960-34762327295a?auto=format&fit=crop&w=900&q=80', categoryTag: 'Religious',
      ),
      EventType(
        id: '5',
        name: "Aarav's First Birthday",
        dateText: 'Feb 18 • 5:00 PM',
        imageUrl:
            'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?auto=format&fit=crop&w=900&q=80', categoryTag: 'Birthday',
      ),
      EventType(
        id: '6',
        name: "Neha & Karan Engagement",
        dateText: 'Mar 03 • 6:30 PM',
        imageUrl:
            'https://images.unsplash.com/photo-1523438885200-e635ba2c371e?auto=format&fit=crop&w=900&q=80', categoryTag: 'Birthday',
      ),
      EventType(
        id: '7',
        name: "Corporate Annual Meetup",
        dateText: 'Apr 22 • 9:00 AM',
        imageUrl:
            'https://images.unsplash.com/photo-1515169067865-5387ec356754?auto=format&fit=crop&w=900&q=80', categoryTag: 'Corporate',
      ),
      EventType(
        id: '8',
        name: "Priya & Rahul Wedding",
        dateText: 'May 14 • 7:00 PM',
        imageUrl:
            'https://images.unsplash.com/photo-1545232979-8bf68ee9b1af?auto=format&fit=crop&w=900&q=80', categoryTag: 'Engagement',
      ),
    ];

    final int columns = width < 600
        ? 1
        : width < 1024
        ? 2
        : 4;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Elegant Events'),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CategoryFilterBar(),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Featured Celebrations',
                  subtitle: 'Hand-picked events just for you',
                  onSeeAll: null, // or () {}
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    itemCount: 8,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (_, index) {
                      return EventCard(event: mockEvents[index], onTap: () {
                        
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
