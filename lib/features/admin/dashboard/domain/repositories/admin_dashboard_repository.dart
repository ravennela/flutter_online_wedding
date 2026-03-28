import 'package:dartz/dartz.dart';
import '../entities/admin_dashboard_entity.dart';

abstract class AdminDashboardRepository {
  Future<Either<String, AdminDashboardEntity>> getAdminDashboardData();
}
