import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/cities/domain/models/city_item.dart';

abstract class CityRepository {
  /// Fetches list of cities from public API.
  Future<Either<String, List<CityItem>>> getCities();

  /// Saves selected city to local storage.
  Future<void> saveSelectedCity(String cityId, String cityName);

  /// Loads selected city from local storage.
  Future<({String? cityId, String? cityName})> loadSelectedCity();

  /// Clears selected city from storage.
  Future<void> clearSelectedCity();
}
