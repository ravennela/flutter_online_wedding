import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_online/core/errors/exceptions.dart';
import 'package:flutter_online/features/cities/data/datasources/city_local_storage.dart';
import 'package:flutter_online/features/cities/data/sources/city_remote_source.dart';
import 'package:flutter_online/features/cities/domain/models/city_item.dart';
import 'package:flutter_online/features/cities/domain/repositories/city_repository.dart';

class CityRepositoryImpl implements CityRepository {
  final CityRemoteSource remoteSource;
  final CityLocalStorage localStorage;

  CityRepositoryImpl({
    required this.remoteSource,
    required this.localStorage,
  });

  @override
  Future<Either<String, List<CityItem>>> getCities() async {
    try {
      final response = await remoteSource.getCities();
      final items = response.map((e) => CityItem.fromJson(e)).toList();
      return Right(items);
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
  Future<void> saveSelectedCity(String cityId, String cityName) async {
    await localStorage.saveSelectedCity(cityId, cityName);
  }

  @override
  Future<({String? cityId, String? cityName})> loadSelectedCity() async {
    return localStorage.loadSelectedCity();
  }

  @override
  Future<void> clearSelectedCity() async {
    await localStorage.clearSelectedCity();
  }
}
