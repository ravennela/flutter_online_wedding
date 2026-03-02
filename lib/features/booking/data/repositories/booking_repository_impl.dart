import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../sources/booking_remote_source.dart';
import '../models/booking_model.dart';
import '../models/booking_page_result.dart';
import '../models/booking_detail_model.dart';

abstract class BookingRepository {
  Future<Either<Failure, BookingPageResult>> getMyBookingsPage(int page, int size);
  Future<Either<Failure, BookingDetailModel>> getBookingDetail(String bookingId);
  Future<Either<Failure, void>> cancelBooking(String bookingId);
  Future<Either<Failure, BookingModel>> createBooking(String eventId, Map<String, dynamic> bookingData);
  Future<Either<Failure, BookingModel>> confirmBooking(String bookingId);
}

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteSource remoteSource;

  BookingRepositoryImpl(this.remoteSource);

  @override
  Future<Either<Failure, BookingPageResult>> getMyBookingsPage(int page, int size) async {
    try {
      final result = await remoteSource.getMyBookingsPage(page, size);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingDetailModel>> getBookingDetail(String bookingId) async {
    try {
      final result = await remoteSource.getBookingById(bookingId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    try {
      await remoteSource.cancelBooking(bookingId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
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
