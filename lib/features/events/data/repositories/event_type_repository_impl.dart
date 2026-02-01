import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_online/core/errors/exceptions.dart';
import 'package:flutter_online/features/events/data/sources/event_type_remote_source.dart';
import 'package:flutter_online/features/events/domain/models/create_event_type_model.dart';
import 'package:flutter_online/features/events/domain/models/event_type_list_response.dart';
import 'package:flutter_online/features/events/domain/repositories/event_type_repository.dart';

class EventTypeRepositoryImpl implements EventTypeRepository {
  final EventTypeRemoteDatasource remoteDatasource;

  EventTypeRepositoryImpl({required this.remoteDatasource});

  /// ➕ Create Event Type
  @override
  Future<Either<String, CreateEventTypeModel>> createEventTypeRepo(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await remoteDatasource.createEventType(data);
      return Right(CreateEventTypeModel.fromJson(response));
    } on SocketException {
      return const Left("No internet connection");
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
      return const Left("Something went wrong");
    }
  }

  /// 📄 Fetch Event Types
  @override
  Future<Either<String, EventTypeListResponse>> fetchEventTypesRepo({
    required int page,
    required int size,
    String? search,
    bool? active,
  }) async {
    try {
      final response = await remoteDatasource.fetchEventTypes(
        page: page,
        size: size,
        search: search,
        active: active,
      );
      return Right(EventTypeListResponse.fromJson(response));
    } on SocketException {
      return const Left("No internet connection");
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
      return const Left("Something went wrong");
    }
  }
}
