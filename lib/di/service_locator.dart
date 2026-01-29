import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../features/auth/data/sources/auth_remote_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/events/data/sources/event_remote_source.dart';
import '../features/events/data/repositories/event_repository_impl.dart';
import '../features/booking/data/sources/booking_remote_source.dart';
import '../features/booking/data/repositories/booking_repository_impl.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  getIt.registerLazySingleton(() => ApiClient());
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(Connectivity()),
  );
  
  // Auth
  getIt.registerLazySingleton<AuthRemoteSource>(
    () => AuthRemoteSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(getIt<AuthRemoteSource>()),
  );
  
  // Events
  getIt.registerLazySingleton<EventRemoteSource>(
    () => EventRemoteSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<EventRepositoryImpl>(
    () => EventRepositoryImpl(getIt<EventRemoteSource>()),
  );
  
  // Booking
  getIt.registerLazySingleton<BookingRemoteSource>(
    () => BookingRemoteSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<BookingRepositoryImpl>(
    () => BookingRepositoryImpl(getIt<BookingRemoteSource>()),
  );
}
