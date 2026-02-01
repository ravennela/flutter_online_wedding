import 'package:flutter_online/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_online/features/auth/domain/usecase/send_otp_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../features/auth/data/sources/auth_remote_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/events/data/sources/event_remote_source.dart';
import '../features/events/data/repositories/event_repository_impl.dart';
import '../features/events/data/sources/event_type_remote_source.dart';
import '../features/events/data/repositories/event_type_repository_impl.dart';
import '../features/events/domain/repositories/event_type_repository.dart';
import '../features/events/domain/usecases/event_type_usecase.dart';
import '../features/events/domain/usecases/fetch_event_types_usecase.dart';
import '../features/events/bloc/event_type/event_type_bloc.dart';
import '../features/booking/data/sources/booking_remote_source.dart';
import '../features/booking/data/repositories/booking_repository_impl.dart';
import '../features/decorations/data/sources/decoration_remote_source.dart';
import '../features/decorations/data/repositories/decoration_repository_impl.dart';
import '../features/decorations/domain/repositories/decoration_repository.dart';
import '../features/decorations/domain/usecases/create_decoration_usecase.dart';
import '../features/decorations/domain/usecases/fetch_cities_usecase.dart';
import '../features/decorations/domain/usecases/get_decorations_usecase.dart';
import '../features/decorations/presentation/bloc/create_decoration_bloc.dart';
import '../features/decorations/presentation/bloc/admin_decoration_list_cubit.dart';

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

  // Event Types (Admin)
  getIt.registerLazySingleton<EventTypeRemoteDatasource>(
    () => EventTypeRemoteDatasourceImpl(dioClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<EventTypeRepository>(
    () => EventTypeRepositoryImpl(remoteDatasource: getIt<EventTypeRemoteDatasource>()),
  );
  getIt.registerLazySingleton<CreateEventTypeUsecase>(
    () => CreateEventTypeUsecase(repository: getIt<EventTypeRepository>()),
  );
  getIt.registerLazySingleton<FetchEventTypesUsecase>(
    () => FetchEventTypesUsecase(repository: getIt<EventTypeRepository>()),
  );
  getIt.registerFactory<EventTypeBloc>(
    () => EventTypeBloc(
      createEventTypeUsecase: getIt<CreateEventTypeUsecase>(),
      fetchEventTypesUsecase: getIt<FetchEventTypesUsecase>(),
    ),
  );

  getIt.registerLazySingleton<SendOtpUsecase>(()=>
      SendOtpUsecase(repository: getIt<AuthRepositoryImpl>()));

  // Decorations (Admin)
  getIt.registerLazySingleton<DecorationRemoteSource>(
    () => DecorationRemoteSourceImpl(dioClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DecorationRepository>(
    () => DecorationRepositoryImpl(remoteSource: getIt<DecorationRemoteSource>()),
  );
  getIt.registerLazySingleton<CreateDecorationUsecase>(
    () => CreateDecorationUsecase(repository: getIt<DecorationRepository>()),
  );
  getIt.registerLazySingleton<FetchCitiesUsecase>(
    () => FetchCitiesUsecase(repository: getIt<DecorationRepository>()),
  );
  getIt.registerFactory<CreateDecorationBloc>(
    () => CreateDecorationBloc(
      createDecorationUsecase: getIt<CreateDecorationUsecase>(),
      fetchCitiesUsecase: getIt<FetchCitiesUsecase>(),
      fetchEventTypesUsecase: getIt<FetchEventTypesUsecase>(),
    ),
  );
  getIt.registerFactory<AuthBloc>(()=> AuthBloc( getIt<SendOtpUsecase>()));
  getIt.registerLazySingleton<GetDecorationsUseCase>(
    () => GetDecorationsUseCase(getIt<DecorationRepository>()),
  );
  getIt.registerFactory<AdminDecorationListCubit>(
    () => AdminDecorationListCubit(getIt<GetDecorationsUseCase>()),
  );

  // Booking
  getIt.registerLazySingleton<BookingRemoteSource>(
    () => BookingRemoteSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<BookingRepositoryImpl>(
    () => BookingRepositoryImpl(getIt<BookingRemoteSource>()),
  );
}
