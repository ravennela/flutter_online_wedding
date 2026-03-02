import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/app.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_online/features/cities/presentation/cubit/city_cubit.dart';
import 'package:flutter_online/features/decorations/presentation/bloc/admin_decoration_list_bloc.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();

  final cityCubit = getIt<CityCubit>();
  await cityCubit.loadCityFromStorage();

  final authCubit = getIt<AuthCubit>();
  await authCubit.checkAuthStatus();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider(create: (_) => getIt<EventTypeBloc>()),
        BlocProvider(create: (_) => getIt<AdminDecorationListBloc>()),
        BlocProvider(create: (_) => cityCubit),
      ],
      child: WeddingApp(),
    ),
  );
}
