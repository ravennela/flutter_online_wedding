import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_online/core/errors/exceptions.dart';
import 'package:flutter_online/features/public_events/data/sources/public_events_remote_source.dart';
import 'package:flutter_online/features/public_events/domain/models/public_event_item.dart';
import 'package:flutter_online/features/public_events/domain/repositories/public_events_repository.dart';

class PublicEventsRepositoryImpl implements PublicEventsRepository {
  final PublicEventsRemoteSource remoteSource;

  PublicEventsRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<String, List<PublicEventItem>>> getPublicEvents() async {
    try {
      final response = await remoteSource.getPublicEvents();
      final items = response
          .map((e) => PublicEventItem.fromJson(e))
          .toList();
      return Right(items);
    } on SocketException {
      return const Left('No internet connection');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
          : null;
      return Left(
        msg?.toString() ?? e.message ?? 'Server error occurred',
      );
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return const Left('Something went wrong');
    }
  }
}
