import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_online/features/auth/presentation/screens/otp_screen.dart';

import 'package:flutter_online/features/events/bloc/event_type/event_type_event.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_bloc.dart';
import 'package:flutter_online/features/home/presentation/home_screen.dart';
import 'package:flutter_online/features/events/presentation/pages/event_list_page.dart';
import 'package:flutter_online/features/decorations/presentation/pages/decoration_list_page.dart';
import 'package:flutter_online/features/decorations/presentation/pages/decoration_detail_page.dart';
import 'package:flutter_online/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:flutter_online/features/admin/presentation/pages/event_types_page.dart';
import 'package:flutter_online/features/admin/presentation/pages/create_event_type_page.dart';
import 'package:flutter_online/features/admin/presentation/pages/admin_decorations_page.dart';
import 'package:flutter_online/features/admin/presentation/pages/admin_create_decoration_page.dart';
import 'package:flutter_online/features/decorations/presentation/bloc/create_decoration_bloc.dart';
import 'package:flutter_online/features/decorations/presentation/bloc/create_decoration_event.dart';
import 'app_routes.dart';

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      name: 'home',
      path: AppRoutes.splash,
      builder: (context, state) => const PublicHomePage(),
    ),
    GoRoute(
      path: AppRoutes.eventList,
      builder: (context, state) => const EventListPage(),
    ),
    GoRoute(
      path: '/events/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return DecorationListPage(eventId: id);
      },
    ),
    GoRoute(
      path: '/decoration/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return DecorationDetailPage(decorationId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.adminDashboard,
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.adminEventTypes,
      builder: (context, state) => BlocProvider(
        create: (_) =>
            getIt<EventTypeBloc>()
              ..add(const FetchEventTypes(page: 0, size: 10)),
        child: const EventTypesPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.adminEventTypesCreate,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<EventTypeBloc>(),
        child: const CreateEventTypePage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.adminDecorations,
      builder: (context, state) => AdminDecorationsPage(),
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminDecorationsCreate,
      builder: (context, state) => BlocProvider(
        create: (_) =>
            getIt<CreateDecorationBloc>()..add(const LoadEventTypesAndCities()),
        child: const AdminCreateDecorationPage(),
      ),
    ),
  ],
);
