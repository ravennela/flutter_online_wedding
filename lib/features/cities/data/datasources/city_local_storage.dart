import 'package:shared_preferences/shared_preferences.dart';

abstract class CityLocalStorage {
  Future<void> saveSelectedCity(String cityId, String cityName);
  Future<({String? cityId, String? cityName})> loadSelectedCity();
  Future<void> clearSelectedCity();
}

const String _keyCityId = 'selected_city_id';
const String _keyCityName = 'selected_city_name';

class CityLocalStorageImpl implements CityLocalStorage {
  final SharedPreferences _prefs;

  CityLocalStorageImpl(this._prefs);

  @override
  Future<void> saveSelectedCity(String cityId, String cityName) async {
    await _prefs.setString(_keyCityId, cityId);
    await _prefs.setString(_keyCityName, cityName);
  }

  @override
  Future<({String? cityId, String? cityName})> loadSelectedCity() async {
    return (
      cityId: _prefs.getString(_keyCityId),
      cityName: _prefs.getString(_keyCityName),
    );
  }

  @override
  Future<void> clearSelectedCity() async {
    await _prefs.remove(_keyCityId);
    await _prefs.remove(_keyCityName);
  }
}
