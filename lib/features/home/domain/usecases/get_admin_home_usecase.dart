import 'package:dartz/dartz.dart';
import 'package:flutter_online/features/home/domain/models/admin_home_model.dart';
import 'package:flutter_online/features/home/domain/repositories/admin_home_repository.dart';

class GetAdminHomeUsecase {
  final AdminHomeRepository repository;

  GetAdminHomeUsecase({required this.repository});

  Future<Either<String, AdminHomeModel>> call() async {
    return repository.getAdminHome();
  }
}
