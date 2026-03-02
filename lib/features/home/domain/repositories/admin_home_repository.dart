import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/home/domain/models/admin_home_model.dart';

abstract class AdminHomeRepository {
  /// Fetches admin home content (hero, categories, services, featured event,
  /// real celebrations, trending decorations).
  Future<Either<String, AdminHomeModel>> getAdminHome();
}
