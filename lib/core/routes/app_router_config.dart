import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/go_router_refresh_stream.dart';
import 'package:flutter_online/features/admin/presentation/pages/edit_deceration_page.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_online/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_online/features/auth/presentation/screens/otp_screen.dart';
import 'package:flutter_online/features/decorations/presentation/bloc/create_decoration_bloc.dart';
import 'package:flutter_online/features/decorations/presentation/bloc/decoration_detail_bloc.dart';
import 'package:flutter_online/features/decorations/presentation/bloc/update_decoration_bloc.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_event.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_bloc.dart';
import 'package:flutter_online/features/home/presentation/bloc/admin_home_bloc.dart';
import 'package:flutter_online/features/home/presentation/bloc/admin_home_event.dart';
import 'package:flutter_online/features/home/presentation/home_screen.dart';
import 'package:flutter_online/features/events/presentation/pages/event_list_page.dart';
import 'package:flutter_online/features/public_events/presentation/bloc/public_events_bloc.dart';
import 'package:flutter_online/features/public_events/presentation/bloc/public_events_event.dart';
import 'package:flutter_online/features/decorations/presentation/pages/decoration_list_page.dart';
import 'package:flutter_online/features/decorations/presentation/pages/decoration_detail_page.dart';
import 'package:flutter_online/features/decorations/presentation/pages/public_decoration_detail_page.dart';
import 'package:flutter_online/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:flutter_online/features/admin/presentation/pages/event_types_page.dart';
import 'package:flutter_online/features/admin/presentation/pages/create_event_type_page.dart';
import 'package:flutter_online/features/admin/presentation/pages/admin_decorations_page.dart';
import 'package:flutter_online/features/admin/presentation/pages/admin_create_decoration_page.dart';
import 'package:flutter_online/features/admin/presentation/pages/event_type_detail_page.dart';
import 'package:flutter_online/features/admin/presentation/pages/decoration_detail_page.dart'
    as admin_decoration_detail;
import 'package:flutter_online/features/admin/bookings/presentation/pages/admin_bookings_page.dart';
import 'package:flutter_online/features/cities/presentation/cubit/city_cubit.dart';
import 'package:flutter_online/features/cities/presentation/pages/city_selection_page.dart';
import 'package:flutter_online/features/decorations/presentation/bloc/events/create_decoration_event.dart';
import 'package:flutter_online/features/auth/domain/models/login_redirect_data.dart';
import 'package:flutter_online/features/auth/domain/models/otp_screen_args.dart';
import 'package:flutter_online/features/booking/presentation/pages/booking_page.dart';
import 'package:flutter_online/features/address/presentation/pages/add_address_page.dart';
import 'package:flutter_online/features/address/presentation/pages/address_list_page.dart';
import 'package:flutter_online/features/booking/domain/models/booking_args.dart';
import 'package:flutter_online/features/booking/presentation/pages/select_event_date_page.dart';
import 'package:flutter_online/features/booking/presentation/pages/payment_method_page.dart';
import 'package:flutter_online/features/booking/presentation/pages/booking_success_page.dart';
import 'package:flutter_online/features/booking/presentation/pages/my_bookings_page.dart';
import 'package:flutter_online/features/booking/presentation/pages/booking_detail_page.dart';
import 'package:flutter_online/features/booking/bloc/booking_bloc.dart';
import 'package:flutter_online/features/payment/bloc/payment_bloc.dart';
import 'app_routes.dart';

final AuthCubit authCubit = getIt<AuthCubit>();
final CityCubit cityCubit = getIt<CityCubit>();

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.splash,
  refreshListenable: MultiStreamRefreshNotifier([
    authCubit.stream,
    cityCubit.stream,
  ]),
  routes: [
    GoRoute(
      path: AppRoutes.citySelection,
      builder: (context, state) => const CitySelectionPage(),
    ),
    GoRoute(
      name: 'home',
      path: AppRoutes.splash,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<AdminHomeBloc>()..add(const FetchAdminHome()),
        child: const PublicHomePage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventList,
      builder: (context, state) => BlocProvider(
        create: (_) =>
            getIt<PublicEventsBloc>()..add(const FetchPublicEvents()),
        child: const EventListPage(),
      ),
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
        return PublicDecorationDetailPage(decorationId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.adminDashboard,
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.adminBookings,
      builder: (context, state) => const AdminBookingsPage(),
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
      path: '${AppRoutes.adminEventTypesDetail}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return EventTypeDetailPage(id: id);
      },
    ),
    GoRoute(
      path: '${AppRoutes.adminEventTypesEdit}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return BlocProvider(
          create: (_) => getIt<EventTypeBloc>(),
          child: CreateEventTypePage(id: id),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.adminDecorations,
      builder: (context, state) => AdminDecorationsPage(),
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) {
        final redirectData = state.extra;
        return LoginScreen(
          redirectData: redirectData is LoginRedirectData ? redirectData : null,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! OtpScreenArgs) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              GoRouter.of(context).go(AppRoutes.login);
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return OtpScreen(args: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.booking,
      builder: (context, state) {
        final decorationId = state.extra;
        if (decorationId is! String) {
          return _buildSessionExpiredFallback(context);
        }
        return BookingPage(decorationId: decorationId);
      },
    ),
    GoRoute(
      path: AppRoutes.selectEventDate,
      builder: (context, state) {
        final args = state.extra;
        if (args is! BookingArgs) {
          return _buildSessionExpiredFallback(context);
        }
        return SelectEventDatePage(args: args);
      },
    ),
    GoRoute(
      path: AppRoutes.paymentMethod,
      builder: (context, state) {
        final args = state.extra;
        if (args is! BookingArgs) {
          return _buildSessionExpiredFallback(context);
        }
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<BookingBloc>()),
            BlocProvider(create: (context) => getIt<PaymentBloc>()),
          ],
          child: PaymentMethodPage(args: args),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.bookingSuccess,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        return BookingSuccessPage(
          bookingId: extras['bookingId'],
          amount: extras['amount'],
          date: extras['date'],
        );
      },
    ),

    GoRoute(
      path: AppRoutes.adminDecorationsCreate,
      builder: (context, state) => BlocProvider(
        create: (_) =>
            getIt<CreateDecorationBloc>()..add(const LoadEventTypesAndCities()),
        child: const AdminCreateDecorationPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.adminDecorationsDetail,
      builder: (context, state) {
        final decorationId = state.extra as String;
        return DecorationDetailPage(decorationId: decorationId);
      },
    ),

    GoRoute(
      path: AppRoutes.editDeceoration,
      builder: (context, state) {
        final decorationId = state.extra as String;
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  getIt<CreateDecorationBloc>()..add(const LoadEventTypesAndCities()),
            ),
            BlocProvider(
              create: (_) => getIt<DecorationDetailBloc>()
                ..add(LoadDecorationDetail(decorationId)),
            ),
            BlocProvider(
              create: (_) => getIt<UpdateDecorationBloc>(),
            ),
          ],
          child: EditDecerationPage(decorationId: decorationId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.addAddress,
      builder: (context, state) => const AddAddressPage(),
    ),
    GoRoute(
      path: AppRoutes.addressList,
      builder: (context, state) => const AddressListPage(),
    ),
    GoRoute(
      path: AppRoutes.myBookings,
      builder: (context, state) => const MyBookingsPage(),
    ),
    GoRoute(
      path: '${AppRoutes.bookingDetail}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return BookingDetailPage(bookingId: id.isNotEmpty ? id : null);
      },
    ),
  ],
  redirect: (context, state) {
    final authState = authCubit.state;
    final cityState = cityCubit.state;
    final location = state.matchedLocation;

    final isCitySelection = location == AppRoutes.citySelection;
    final isLogin = location == AppRoutes.login;
    final isOtp = location == AppRoutes.otp;
    final isPublic =
        location == AppRoutes.splash ||
        location == AppRoutes.eventList ||
        location.startsWith('/events') ||
        location.startsWith('/decoration');

    // 1. MANDATORY CITY: Only redirect when no city ever selected (CityInitial).
    // Do NOT redirect during CityLoading/CityListLoaded (user changing city from sheet).
    final hasNoCity = cityState is CityInitial;
    if (hasNoCity && !isCitySelection) {
      return AppRoutes.citySelection;
    }

    // 1b. OTP route requires OtpScreenArgs (e.g. refresh loses extra)
    if (isOtp && state.extra is! OtpScreenArgs) {
      return AppRoutes.login;
    }

    // 2. 🔄 While checking auth → stay put
    if (authState is AuthLoading) {
      return null;
    }

    // 3. 🔓 Not logged in (guest mode - allow browsing public routes)
    if (authState is AuthUnauthenticated) {
      if (isPublic || isLogin || isOtp) return null;
      // Redirect to home when on protected routes (admin, booking, my bookings)
      if (location.startsWith('/admin') ||
          location == AppRoutes.booking ||
          location == AppRoutes.myBookings ||
          location.startsWith('${AppRoutes.myBookings}/')) {
        return AppRoutes.splash;
      }
      return null;
    }

    // 4. 🔐 Logged in
    if (authState is AuthAuthenticated) {
      final role = authState.user.role;

      // When at OTP: do NOT redirect - let BlocListener's onLoginSuccess handle
      // navigation (preserves redirectData for Book Now, etc.)
      if (isOtp) return null;

      if (isLogin) {
        return role == 'ADMIN' ? AppRoutes.adminDashboard : AppRoutes.splash;
      }

      if (location.startsWith('/admin') && role != 'ADMIN') {
        return AppRoutes.splash;
      }
    }

    return null;
  },
);

Widget _buildSessionExpiredFallback(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history_outlined,
                  size: 48,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Session Expired',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'For your security, booking data is not stored in history. Please re-select your preferred event.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
