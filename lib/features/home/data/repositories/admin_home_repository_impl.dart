import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_online/core/errors/exceptions.dart';
import 'package:flutter_online/features/home/data/sources/admin_home_remote_source.dart';
import 'package:flutter_online/features/home/domain/models/admin_home_model.dart';
import 'package:flutter_online/features/home/domain/repositories/admin_home_repository.dart';

class AdminHomeRepositoryImpl implements AdminHomeRepository {
  final AdminHomeRemoteSource remoteSource;

  AdminHomeRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<String, AdminHomeModel>> getAdminHome() async {
    try {
      final response = await remoteSource.getAdminHome();
      return Right(AdminHomeModel.fromJson(response));
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
