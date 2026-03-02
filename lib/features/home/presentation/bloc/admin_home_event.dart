import 'package:equatable/equatable.dart';

abstract class AdminHomeEvent extends Equatable {
  const AdminHomeEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches admin home content (hero, categories, services, etc.)
class FetchAdminHome extends AdminHomeEvent {
  const FetchAdminHome();
}
