import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/public_events/domain/models/public_event_item.dart';

abstract class PublicEventsRepository {
  /// Fetches public event types for user-side events list.
  Future<Either<String, List<PublicEventItem>>> getPublicEvents();
}
