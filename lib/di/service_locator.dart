import 'package:flutter_online/features/auth/data/datasources/token_storage.dart';
import 'package:flutter_online/features/auth/domain/usecase/send_otp_usecase.dart';
import 'package:flutter_online/features/auth/domain/usecase/verify_otp_usecase.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_online/features/address/data/datasources/address_remote_datasource.dart';
import 'package:flutter_online/features/address/data/repositories/address_repository_impl.dart';
import 'package:flutter_online/features/address/domain/repositories/address_repository.dart';
import 'package:flutter_online/features/address/domain/usecases/create_address_usecase.dart';
import 'package:flutter_online/features/address/domain/usecases/get_addresses_usecase.dart';
import 'package:flutter_online/features/address/domain/usecases/delete_address_usecase.dart';
import 'package:flutter_online/features/address/presentation/cubit/add_address_cubit.dart';
import 'package:flutter_online/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_online/features/booking/bloc/booking_bloc.dart';
import 'package:flutter_online/features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'package:flutter_online/features/booking/domain/usecases/get_booking_detail_usecase.dart';
import 'package:flutter_online/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:flutter_online/features/booking/presentation/bloc/booking_detail_bloc.dart';
import 'package:flutter_online/features/decorations/domain/usecases/delete_decoration_usecase.dart';
import 'package:flutter_online/features/decorations/domain/usecases/get_decoration_by_id_usecase.dart';
import 'package:flutter_online/core/network/unauthorized_notifier.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import '../features/events/domain/usecases/update_event_type_usecase.dart';
import '../features/events/domain/usecases/get_event_type_by_id_usecase.dart';
import '../features/events/bloc/event_type/event_type_bloc.dart';
import '../features/booking/data/sources/booking_remote_source.dart';
import '../features/booking/data/repositories/booking_repository_impl.dart';
import '../features/decorations/data/sources/decoration_remote_source.dart';
import '../features/decorations/data/repositories/decoration_repository_impl.dart';
import '../features/decorations/domain/repositories/decoration_repository.dart';
import '../features/decorations/domain/usecases/create_decoration_usecase.dart';
import '../features/decorations/domain/usecases/fetch_cities_usecase.dart';
import '../features/decorations/domain/usecases/get_decorations_usecase.dart';
import '../features/decorations/domain/usecases/update_decoration_usecase.dart';
import '../features/decorations/presentation/bloc/admin_decoration_list_bloc.dart';
import '../features/decorations/presentation/bloc/create_decoration_bloc.dart';
import '../features/decorations/presentation/bloc/decoration_detail_bloc.dart';
import '../features/decorations/presentation/bloc/update_decoration_bloc.dart';
import '../features/home/data/repositories/admin_home_repository_impl.dart';
import '../features/home/data/sources/admin_home_remote_source.dart';
import '../features/home/domain/repositories/admin_home_repository.dart';
import '../features/home/domain/usecases/get_admin_home_usecase.dart';
import '../features/home/presentation/bloc/admin_home_bloc.dart';
import '../features/public_events/data/repositories/public_events_repository_impl.dart';
import '../features/public_events/data/sources/public_events_remote_source.dart';
import '../features/public_events/domain/repositories/public_events_repository.dart';
import '../features/public_events/domain/usecases/get_public_events_usecase.dart';
import '../features/public_events/presentation/bloc/public_events_bloc.dart';
import '../features/cities/data/datasources/city_local_storage.dart';
import '../features/cities/data/repositories/city_repository_impl.dart';
import '../features/cities/data/sources/city_remote_source.dart';
import '../features/cities/domain/repositories/city_repository.dart';
import '../features/cities/presentation/cubit/city_cubit.dart';
import '../features/decorations/data/repositories/public_decoration_repository_impl.dart';
import '../features/decorations/data/sources/public_decoration_remote_source.dart';
import '../features/decorations/domain/repositories/public_decoration_repository.dart';
import '../features/decorations/presentation/cubit/decoration_detail_cubit.dart';
import '../features/decorations/presentation/cubit/decoration_list_cubit.dart';
import '../features/payment/data/sources/payment_remote_source.dart';
import '../features/payment/domain/repositories/payment_repository.dart';
import '../features/payment/data/repositories/payment_repository_impl.dart';
import '../features/payment/domain/usecases/create_order_usecase.dart';
import '../features/payment/bloc/payment_bloc.dart';
import '../features/admin/bookings/data/datasources/admin_booking_remote_datasource.dart';
import '../features/admin/bookings/data/repositories/admin_booking_repository_impl.dart';
import '../features/admin/bookings/domain/repositories/admin_booking_repository.dart';
import '../features/admin/bookings/domain/usecases/get_admin_bookings_usecase.dart';
import '../features/admin/bookings/presentation/bloc/admin_bookings_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerLazySingleton<UnauthorizedNotifier>(
    () => UnauthorizedNotifier(),
  );
  getIt.registerLazySingleton<TokenStorage>(
    () => TokenStorageImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton(() => ApiClient(
        tokenStorage: getIt<TokenStorage>(),
        unauthorizedNotifier: getIt<UnauthorizedNotifier>(),
      ));
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
    () => EventTypeRepositoryImpl(
      remoteDatasource: getIt<EventTypeRemoteDatasource>(),
    ),
  );
  getIt.registerLazySingleton<CreateEventTypeUsecase>(
    () => CreateEventTypeUsecase(repository: getIt<EventTypeRepository>()),
  );
  getIt.registerLazySingleton<FetchEventTypesUsecase>(
    () => FetchEventTypesUsecase(repository: getIt<EventTypeRepository>()),
  );
  getIt.registerLazySingleton<UpdateEventTypeUseCase>(
    () => UpdateEventTypeUseCase(repository: getIt<EventTypeRepository>()),
  );
  getIt.registerLazySingleton<GetEventTypeByIdUseCase>(
    () => GetEventTypeByIdUseCase(getIt<EventTypeRepository>()),
  );
  getIt.registerFactory<EventTypeBloc>(
    () => EventTypeBloc(
      createEventTypeUsecase: getIt<CreateEventTypeUsecase>(),
      fetchEventTypesUsecase: getIt<FetchEventTypesUsecase>(),
      updateEventTypeUsecase: getIt<UpdateEventTypeUseCase>(),
      getEventTypeByIdUseCase: getIt<GetEventTypeByIdUseCase>(),
    ),
  );

  getIt.registerLazySingleton<SendOtpUsecase>(
    () => SendOtpUsecase(repository: getIt<AuthRepositoryImpl>()),
  );
  getIt.registerLazySingleton<VerifyOtpUsecase>(
    () => VerifyOtpUsecase(getIt<AuthRepositoryImpl>()),
  );

  // Decorations (Admin)
  getIt.registerLazySingleton<DecorationRemoteSource>(
    () => DecorationRemoteSourceImpl(dioClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DecorationRepository>(
    () =>
        DecorationRepositoryImpl(remoteSource: getIt<DecorationRemoteSource>()),
  );
  getIt.registerLazySingleton<CreateDecorationUsecase>(
    () => CreateDecorationUsecase(repository: getIt<DecorationRepository>()),
  );
  getIt.registerLazySingleton<FetchCitiesUsecase>(
    () => FetchCitiesUsecase(repository: getIt<DecorationRepository>()),
  );
  getIt.registerLazySingleton<UpdateDecorationUseCase>(
    () => UpdateDecorationUseCase(repository: getIt<DecorationRepository>()),
  );
  getIt.registerFactory<CreateDecorationBloc>(
    () => CreateDecorationBloc(
      createDecorationUsecase: getIt<CreateDecorationUsecase>(),
      fetchCitiesUsecase: getIt<FetchCitiesUsecase>(),
      fetchEventTypesUsecase: getIt<FetchEventTypesUsecase>(),
    ),
  );

  getIt.registerFactory<BookingBloc>(
    () => BookingBloc(
      bookingRepository: getIt<BookingRepositoryImpl>(),
      getMyBookingsUseCase: getIt<GetMyBookingsUseCase>(),
    ),
  );
  getIt.registerFactory<BookingDetailBloc>(
    () => BookingDetailBloc(getIt<GetBookingDetailUseCase>(), getIt<CancelBookingUseCase>()),
  );
  getIt.registerLazySingleton<AuthCubit>(
    () {
      final cubit = AuthCubit(
        sendOtpUsecase: getIt<SendOtpUsecase>(),
        verifyOtpUsecase: getIt<VerifyOtpUsecase>(),
        tokenStorage: getIt<TokenStorage>(),
      );
      getIt<UnauthorizedNotifier>().stream.listen((_) {
        cubit.onUnauthorized();
      });
      return cubit;
    },
  );
  getIt.registerLazySingleton<GetDecorationsUseCase>(
    () => GetDecorationsUseCase(getIt<DecorationRepository>()),
  );
  getIt.registerLazySingleton<DeleteDecoration>(
    () => DeleteDecoration(getIt<DecorationRepository>()),
  );
  getIt.registerFactory<AdminDecorationListBloc>(
    () => AdminDecorationListBloc(
      getDecorationsUseCase: getIt<GetDecorationsUseCase>(),
      deleteDecorationUseCase: getIt<DeleteDecoration>(),
    ),
  );
  getIt.registerFactory<DecorationDetailBloc>(
    () => DecorationDetailBloc(
      getDecorationByIdUseCase: getIt<GetDecorationByIdUseCase>(),
    ),
  );
  getIt.registerFactory<UpdateDecorationBloc>(
    () => UpdateDecorationBloc(
      updateDecorationUseCase: getIt<UpdateDecorationUseCase>(),
    ),
  );
  getIt.registerLazySingleton<GetDecorationByIdUseCase>(
    () => GetDecorationByIdUseCase(getIt<DecorationRepository>()),
  );

  // Admin Home (hero, categories, services, featured event, real celebrations, trending decorations)
  getIt.registerLazySingleton<AdminHomeRemoteSource>(
    () => AdminHomeRemoteSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AdminHomeRepository>(
    () => AdminHomeRepositoryImpl(remoteSource: getIt<AdminHomeRemoteSource>()),
  );
  getIt.registerLazySingleton<GetAdminHomeUsecase>(
    () => GetAdminHomeUsecase(repository: getIt<AdminHomeRepository>()),
  );
  getIt.registerFactory<AdminHomeBloc>(
    () => AdminHomeBloc(getAdminHomeUsecase: getIt<GetAdminHomeUsecase>()),
  );

  // Public Events (user-side, separate from admin)
  getIt.registerLazySingleton<PublicEventsRemoteSource>(
    () => PublicEventsRemoteSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<PublicEventsRepository>(
    () => PublicEventsRepositoryImpl(
      remoteSource: getIt<PublicEventsRemoteSource>(),
    ),
  );
  getIt.registerLazySingleton<GetPublicEventsUsecase>(
    () => GetPublicEventsUsecase(
      repository: getIt<PublicEventsRepository>(),
    ),
  );
  getIt.registerFactory<PublicEventsBloc>(
    () => PublicEventsBloc(
      getPublicEventsUsecase: getIt<GetPublicEventsUsecase>(),
    ),
  );

  // Cities (public, with SharedPreferences persistence)
  getIt.registerLazySingleton<CityLocalStorage>(
    () => CityLocalStorageImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<CityRemoteSource>(
    () => CityRemoteSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CityRepository>(
    () => CityRepositoryImpl(
      remoteSource: getIt<CityRemoteSource>(),
      localStorage: getIt<CityLocalStorage>(),
    ),
  );
  getIt.registerLazySingleton<CityCubit>(
    () => CityCubit(getIt<CityRepository>()),
  );

  // Public Decorations (user-side, separate from admin)
  getIt.registerLazySingleton<PublicDecorationRemoteSource>(
    () => PublicDecorationRemoteSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<PublicDecorationRepository>(
    () => PublicDecorationRepositoryImpl(
      remoteSource: getIt<PublicDecorationRemoteSource>(),
    ),
  );
  getIt.registerFactory<DecorationListCubit>(
    () => DecorationListCubit(getIt<PublicDecorationRepository>()),
  );
  getIt.registerFactory<DecorationDetailCubit>(
    () => DecorationDetailCubit(getIt<PublicDecorationRepository>()),
  );

  // Booking
  getIt.registerLazySingleton<BookingRemoteSource>(
    () => BookingRemoteSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<BookingRepositoryImpl>(
    () => BookingRepositoryImpl(getIt<BookingRemoteSource>()),
  );
  getIt.registerLazySingleton<GetMyBookingsUseCase>(
    () => GetMyBookingsUseCase(getIt<BookingRepositoryImpl>()),
  );
  getIt.registerLazySingleton<GetBookingDetailUseCase>(
    () => GetBookingDetailUseCase(getIt<BookingRepositoryImpl>()),
  );
  getIt.registerLazySingleton<CancelBookingUseCase>(
    () => CancelBookingUseCase(getIt<BookingRepositoryImpl>()),
  );

  // Address
  getIt.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(getIt<AddressRemoteDataSource>()),
  );
  getIt.registerLazySingleton<CreateAddressUseCase>(
    () => CreateAddressUseCase(getIt<AddressRepository>()),
  );
   getIt.registerLazySingleton<GetAddressesUseCase>(
    () => GetAddressesUseCase(getIt<AddressRepository>()),
  );
  getIt.registerLazySingleton<DeleteAddressUseCase>(
    () => DeleteAddressUseCase(getIt<AddressRepository>()),
  );
  getIt.registerFactory<AddAddressCubit>(
    () => AddAddressCubit(
      createAddressUseCase: getIt<CreateAddressUseCase>(),
      authCubit: getIt<AuthCubit>(),
    ),
  );
  getIt.registerFactory<AddressCubit>(
    () => AddressCubit(
      getAddressesUseCase: getIt<GetAddressesUseCase>(),
      deleteAddressUseCase: getIt<DeleteAddressUseCase>(),
      authCubit: getIt<AuthCubit>(),
    ),
  );

  // Payment
  getIt.registerLazySingleton<PaymentRemoteSource>(
    () => PaymentRemoteSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(getIt<PaymentRemoteSource>()),
  );
  getIt.registerLazySingleton<CreateOrderUseCase>(
    () => CreateOrderUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerFactory<PaymentBloc>(
    () => PaymentBloc(createOrderUseCase: getIt<CreateOrderUseCase>()),
  );

  // Admin Bookings
  getIt.registerLazySingleton<AdminBookingRemoteDataSource>(
    () => AdminBookingRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AdminBookingRepository>(
    () => AdminBookingRepositoryImpl(getIt<AdminBookingRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetAdminBookingsUseCase>(
    () => GetAdminBookingsUseCase(getIt<AdminBookingRepository>()),
  );
  getIt.registerFactory<AdminBookingsBloc>(
    () => AdminBookingsBloc(getAdminBookingsUseCase: getIt<GetAdminBookingsUseCase>()),
  );
}
