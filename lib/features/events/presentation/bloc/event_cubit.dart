import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/event_type.dart';

// States
abstract class EventState {}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<EventType> events;
  EventLoaded(this.events);
}

class EventError extends EventState {
  final String message;
  EventError(this.message);
}

// Cubit
class EventCubit extends Cubit<EventState> {
  EventCubit() : super(EventInitial());

  void loadEvents() async {
    emit(EventLoading());

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      // Beautiful wedding & celebration images (Unsplash)
      final List<EventType> mockEvents = [
        EventType(
          id: '1',
          name: "Ananya's Saree Function",
          dateText: 'Oct 24 • 6:00 PM',
          categoryTag: 'TRADITIONAL',
          imageUrl:
              'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?auto=format&fit=crop&w=900&q=80',
        ),
        EventType(
          id: '2',
          name: "Vikram's Golden Jubilee",
          dateText: 'Nov 12 • 7:30 PM',
          categoryTag: 'BIRTHDAY',
          imageUrl:
              'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=900&q=80',
        ),
        EventType(
          id: '3',
          name: "The Mehra's Silver Gala",
          dateText: 'Dec 05 • 8:00 PM',
          categoryTag: 'ANNIVERSARY',
          imageUrl:
              'https://images.unsplash.com/photo-1478146896981-6b80fe463330?auto=format&fit=crop&w=900&q=80',
        ),
        EventType(
          id: '4',
          name: "Rohan's Upanayana",
          dateText: 'Jan 10 • 10:30 AM',
          categoryTag: 'TRADITIONAL',
          imageUrl:
              'https://images.unsplash.com/photo-1583939003579-730e3918a945?auto=format&fit=crop&w=900&q=80',
        ),
        EventType(
          id: '5',
          name: "Aarav's First Birthday",
          dateText: 'Feb 18 • 5:00 PM',
          categoryTag: 'BIRTHDAY',
          imageUrl:
              'https://images.unsplash.com/photo-1519225421980-715cb0215aed?auto=format&fit=crop&w=900&q=80',
        ),
        EventType(
          id: '6',
          name: "Neha & Karan Engagement",
          dateText: 'Mar 03 • 6:30 PM',
          categoryTag: 'ENGAGEMENT',
          imageUrl:
              'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?auto=format&fit=crop&w=900&q=80',
        ),
        EventType(
          id: '7',
          name: "Corporate Annual Meetup",
          dateText: 'Apr 22 • 9:00 AM',
          categoryTag: 'CORPORATE',
          imageUrl:
              'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?auto=format&fit=crop&w=900&q=80',
        ),
        EventType(
          id: '8',
          name: "Priya & Rahul Wedding",
          dateText: 'May 14 • 7:00 PM',
          categoryTag: 'WEDDING',
          imageUrl:
              'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=900&q=80',
        ),
      ];

      emit(EventLoaded(mockEvents));
    } catch (e) {
      emit(EventError("Failed to load events"));
    }
  }
}
