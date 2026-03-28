import 'package:dartz/dartz.dart';
import '../entities/admin_dashboard_entity.dart';
import '../repositories/admin_dashboard_repository.dart';

class GetAdminDashboardDataUseCase {
  final AdminDashboardRepository repository;

  GetAdminDashboardDataUseCase({required this.repository});

  Future<Either<String, AdminDashboardEntity>> call() async {
    return await repository.getAdminDashboardData();
  }
}
