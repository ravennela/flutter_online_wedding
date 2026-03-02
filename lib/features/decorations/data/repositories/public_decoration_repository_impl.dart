import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_online/core/errors/exceptions.dart';
import 'package:flutter_online/features/decorations/data/sources/public_decoration_remote_source.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_detail.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_list_response.dart';
import 'package:flutter_online/features/decorations/domain/repositories/public_decoration_repository.dart';

class PublicDecorationRepositoryImpl implements PublicDecorationRepository {
  final PublicDecorationRemoteSource remoteSource;

  PublicDecorationRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<String, PublicDecorationListResponse>> getDecorations({
    required String cityId,
    String? eventTypeId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await remoteSource.getDecorations(
        cityId: cityId,
        eventTypeId: eventTypeId,
        page: page,
        size: size,
      );
      return Right(PublicDecorationListResponse.fromJson(response));
    } on SocketException {
      return const Left('No internet connection');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
          : null;
      return Left(msg?.toString() ?? e.message ?? 'Server error occurred');
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return const Left('Something went wrong');
    }
  }

  @override
  Future<Either<String, PublicDecorationDetail>> getDecorationDetail(
    String id,
  ) async {
    try {
      final response = await remoteSource.getDecorationDetail(id);
      return Right(PublicDecorationDetail.fromJson(response));
    } on SocketException {
      return const Left('No internet connection');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
          : null;
      return Left(msg?.toString() ?? e.message ?? 'Server error occurred');
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return const Left('Something went wrong');
    }
  }
}
