import 'package:go_router/go_router.dart';
import 'package:flutter_online/features/home/presentation/home_screen.dart';
import 'package:flutter_online/features/events/presentation/pages/event_list_page.dart';
import 'package:flutter_online/features/decorations/presentation/pages/decoration_list_page.dart';
import 'package:flutter_online/features/decorations/presentation/pages/decoration_detail_page.dart';
import 'package:flutter_online/features/admin/presentation/pages/admin_dashboard_page.dart';
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
  ],
);
