import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/cities/domain/models/city_item.dart';
import 'package:flutter_online/features/cities/domain/repositories/city_repository.dart';

abstract class CityState {
  const CityState();
}

class CityInitial extends CityState {
  const CityInitial();
}

class CityLoading extends CityState {
  const CityLoading();
}

class CitySelected extends CityState {
  final String cityId;
  final String cityName;

  const CitySelected({required this.cityId, required this.cityName});
}

class CityListLoaded extends CityState {
  final List<CityItem> cities;
  final String? cityId;
  final String? cityName;

  const CityListLoaded(this.cities, {this.cityId, this.cityName});
}

class CityError extends CityState {
  final String message;

  const CityError(this.message);
}

class CityCubit extends Cubit<CityState> {
  final CityRepository repository;

  CityCubit(this.repository) : super(const CityInitial());

  /// Load saved city from SharedPreferences on app start.
  Future<void> loadCityFromStorage() async {
    emit(const CityLoading());
    try {
      final saved = await repository.loadSelectedCity();
      if (saved.cityId != null &&
          saved.cityId!.isNotEmpty &&
          saved.cityName != null &&
          saved.cityName!.isNotEmpty) {
        emit(CitySelected(cityId: saved.cityId!, cityName: saved.cityName!));
      } else {
        emit(const CityInitial());
      }
    } catch (e) {
      emit(CityError(e.toString()));
    }
  }

  /// Load cities list for selection screen/sheet.
  /// Preserves current city when showing change-city sheet.
  Future<void> loadCities() async {
    final currentId = state is CitySelected ? (state as CitySelected).cityId : null;
    final currentName = state is CitySelected ? (state as CitySelected).cityName : null;
    emit(const CityLoading());
    final result = await repository.getCities();
    result.fold(
      (error) => emit(CityError(error)),
      (cities) => emit(CityListLoaded(cities, cityId: currentId, cityName: currentName)),
    );
  }

  /// Select and persist a city. Call after user selects from list.
  Future<void> selectCity(CityItem city) async {
    await repository.saveSelectedCity(city.id, city.name);
    emit(CitySelected(cityId: city.id, cityName: city.name));
  }

  /// Clear saved city from storage. Forces city selection again.
  Future<void> clearCity() async {
    await repository.clearSelectedCity();
    emit(const CityInitial());
  }

  bool get hasCity =>
      state is CitySelected;

  ({String? cityId, String? cityName}) get currentCity {
    if (state is CitySelected) {
      final s = state as CitySelected;
      return (cityId: s.cityId, cityName: s.cityName);
    }
    return (cityId: null, cityName: null);
  }
}
