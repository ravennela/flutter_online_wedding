import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../sources/event_remote_source.dart';
import '../models/event_model.dart';
import '../models/decoration_model.dart';

abstract class EventRepository {
  Future<Either<Failure, List<EventModel>>> getEvents();
  Future<Either<Failure, EventModel>> getEventDetail(String eventId);
}

class EventRepositoryImpl implements EventRepository {
  final EventRemoteSource remoteSource;

  EventRepositoryImpl(this.remoteSource);

  @override
  Future<Either<Failure, List<EventModel>>> getEvents() async {
    try {
      final events = await remoteSource.getEvents();
      return Right(events);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, EventModel>> getEventDetail(String eventId) async {
    try {
      final event = await remoteSource.getEventDetail(eventId);
      return Right(event);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }


  Failure _mapFailure(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is UnauthorizedException) {
      return AuthFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    } else {
      return ServerFailure(exception.message);
    }
  }
}
