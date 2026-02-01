import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/decorations/domain/models/create_decoration_model.dart';
import 'package:flutter_online/features/decorations/domain/models/city_list_item.dart';
import 'package:flutter_online/features/decorations/domain/models/decoration_list_response.dart';


abstract class DecorationRepository {
  /// Create a decoration package (ADMIN).
  Future<Either<String, CreateDecorationModel>> createDecoration(
    Map<String, dynamic> data,
  );

  /// Fetch cities for dropdown (ADMIN).
  Future<Either<String, List<CityListItem>>> fetchCities({
    int page = 0,
    int size = 100,
  });

  /// Fetch decorations (ADMIN).
  Future<Either<String, DecorationListResponse>> fetchDecorations({
    int page = 0,
    int size = 10,
    String? search,
    String? cityId,
    String? eventTypeId,
    bool? active,
    String? sortBy,
    String? sortDir,
  });
}

