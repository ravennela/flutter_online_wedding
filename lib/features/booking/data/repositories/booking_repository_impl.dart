import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../sources/booking_remote_source.dart';
import '../models/booking_model.dart';

abstract class BookingRepository {
  Future<Either<Failure, List<BookingModel>>> getMyBookings();
  Future<Either<Failure, BookingModel>> createBooking(String eventId, Map<String, dynamic> bookingData);
  Future<Either<Failure, BookingModel>> confirmBooking(String bookingId);
}

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteSource remoteSource;
  
  BookingRepositoryImpl(this.remoteSource);
  
  @override
  Future<Either<Failure, List<BookingModel>>> getMyBookings() async {
    try {
      final bookings = await remoteSource.getMyBookings();
      return Right(bookings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, BookingModel>> createBooking(
    String eventId,
    Map<String, dynamic> bookingData,
  ) async {
    try {
      final booking = await remoteSource.createBooking(eventId, bookingData);
      return Right(booking);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, BookingModel>> confirmBooking(String bookingId) async {
    try {
      final booking = await remoteSource.confirmBooking(bookingId);
      return Right(booking);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
