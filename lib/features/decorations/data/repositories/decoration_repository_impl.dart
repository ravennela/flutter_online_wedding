import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_online/core/errors/exceptions.dart';
import 'package:flutter_online/core/errors/failures.dart';
import 'package:flutter_online/features/decorations/data/sources/decoration_remote_source.dart';
import 'package:flutter_online/features/decorations/domain/models/city_list_item.dart';
import 'package:flutter_online/features/decorations/domain/models/create_decoration_model.dart';
import 'package:flutter_online/features/decorations/domain/models/decoration_detail.dart';

import 'package:flutter_online/features/decorations/domain/models/decoration_list_response.dart';
import 'package:flutter_online/features/decorations/domain/repositories/decoration_repository.dart';


class DecorationRepositoryImpl implements DecorationRepository {
  final DecorationRemoteSource remoteSource;

  DecorationRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<String, CreateDecorationModel>> createDecoration(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await remoteSource.createDecoration(data);
      return Right(CreateDecorationModel.fromJson(response));
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
    } on ValidationException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Something went wrong');
    }
  }

  @override
  Future<Either<String, CreateDecorationModel>> updateDecoration(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await remoteSource.updateDecoration(id, data);
      return Right(CreateDecorationModel.fromJson(response));
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
    } on ValidationException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Something went wrong');
    }
  }

  @override
  Future<Either<String, List<CityListItem>>> fetchCities({
    int page = 0,
    int size = 100,
  }) async {
    try {
      final response = await remoteSource.fetchCities(page: page, size: size);
      final list = response
          .map((e) => CityListItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(list);
    } on SocketException {
      return const Left('No internet connection');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
          : null;
      return Left(
        msg?.toString() ?? e.message ?? 'Failed to load cities',
      );
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return const Left('Failed to load cities');
    }
  }

  @override
  Future<Either<String, DecorationListResponse>> fetchDecorations({
    int page = 0,
    int size = 10,
    String? search,
    String? cityId,
    String? eventTypeId,
    bool? active,
    String? sortBy,
    String? sortDir,
  }) async {
    try {
      final response = await remoteSource.fetchDecorations(
        page: page,
        size: size,
        search: search,
        cityId: cityId,
        eventTypeId: eventTypeId,
        active: active,
        sortBy: sortBy,
        sortDir: sortDir,
      );
      return Right(DecorationListResponse.fromJson(response));
    } on SocketException {
      return const Left('No internet connection');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
          : null;
      return Left(
        msg?.toString() ?? e.message ?? 'Failed to load decorations',
      );
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return const Left('Failed to load decorations');
    }
  }

  @override
  Future<Either<Failure, void>> deleteDecoration(String id)async {
    try {
      await remoteSource.deleteDecoration(id);
      return const Right(null);
    } on SocketException {
      return Left(NetworkFailure("No internet connection"));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure("Failed to delete decoration"));
    }
  }

  @override
  Future<Either<String, DecorationDetail>> getDecorationById(String id) async {
    try {
      final response = await remoteSource.getDecorationById(id);
      return Right(DecorationDetail.fromJson(response));
    } on SocketException {
      return const Left('No internet connection');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
          : null;
      return Left(
        msg?.toString() ?? e.message ?? 'Failed to load decoration details',
      );
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return const Left('Failed to load decoration details');
    }
  }
}

