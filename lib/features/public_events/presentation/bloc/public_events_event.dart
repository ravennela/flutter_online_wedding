import 'package:equatable/equatable.dart';

abstract class PublicEventsEvent extends Equatable {
  const PublicEventsEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches public events for user-side events list
class FetchPublicEvents extends PublicEventsEvent {
  const FetchPublicEvents();
}
