import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/public_events/domain/models/public_event_item.dart';
import 'package:flutter_online/features/public_events/domain/repositories/public_events_repository.dart';

class GetPublicEventsUsecase {
  final PublicEventsRepository repository;

  GetPublicEventsUsecase({required this.repository});

  Future<Either<String, List<PublicEventItem>>> call() async {
    return repository.getPublicEvents();
  }
}
