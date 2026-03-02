import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_detail.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_list_response.dart';

abstract class PublicDecorationRepository {
  Future<Either<String, PublicDecorationListResponse>> getDecorations({
    required String cityId,
    String? eventTypeId,
    int page = 0,
    int size = 10,
  });

  Future<Either<String, PublicDecorationDetail>> getDecorationDetail(String id);
}
