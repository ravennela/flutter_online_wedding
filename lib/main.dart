import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/app.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/auth/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => getIt<AuthBloc>(),
      ),
    ],
    child: const
     WeddingApp(),
  )
   );
}
