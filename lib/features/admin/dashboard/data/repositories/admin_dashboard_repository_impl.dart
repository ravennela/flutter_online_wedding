import 'package:dartz/dartz.dart';
import '../../domain/entities/admin_dashboard_entity.dart';
import '../../domain/repositories/admin_dashboard_repository.dart';
import '../sources/admin_dashboard_remote_source.dart';

class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  final AdminDashboardRemoteSource remoteSource;

  AdminDashboardRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<String, AdminDashboardEntity>> getAdminDashboardData() async {
    try {
      final data = await remoteSource.getAdminDashboardData();
      return Right(data);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
