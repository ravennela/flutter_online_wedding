import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/go_router_refresh_stream.dart';
import 'package:flutter_online/features/admin/bookings/models/vendor_model.dart';
import 'package:flutter_online/features/admin/bookings/presentation/bloc/admin_booking_detail_bloc.dart';
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
import 'package:flutter_online/features/events/domain/models/event_type_list_item.dart';
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
import 'package:flutter_online/features/admin/bookings/presentation/pages/admin_booking_detail_page.dart';
import 'package:flutter_online/features/admin/bookings/presentation/pages/edit_booking_page.dart';
import 'package:flutter_online/features/admin/bookings/presentation/pages/select_vendor_screen.dart';
import 'package:flutter_online/features/admin/vendors/presentation/bloc/vendor_bloc.dart';
import 'package:flutter_online/features/admin/vendors/presentation/bloc/vendor_event.dart';
import 'package:flutter_online/features/admin/vendors/presentation/pages/admin_vendors_page.dart';
import 'package:flutter_online/features/decorations/presentation/bloc/admin_decoration_list_bloc.dart';
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
import 'package:flutter_online/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_online/features/profile/presentation/bloc/profile_event.dart';
import 'package:flutter_online/features/profile/presentation/pages/complete_profile_page.dart';
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
      path: '${AppRoutes.decorationDetail}/:id',
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
      path: AppRoutes.adminBookingDetail,
      builder: (context, state) {
        final bookingId =
            state.extra as String? ?? (state.pathParameters['id']);
        return AdminBookingDetailPage(bookingId: bookingId);
      },
    ),
    GoRoute(
      path: AppRoutes.adminEditBooking,
      builder: (context, state) {
        final bookingId = state.extra as String? ?? state.pathParameters['id'];
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  getIt<AdminBookingDetailBloc>()
                    ..add(FetchBookingDetail(bookingId!)),
            ),
            BlocProvider(create: (_) => getIt<VendorBloc>()),
            BlocProvider(
              create: (_) =>
                  getIt<AdminDecorationListBloc>()
                    ..add(LoadAdminDecorations(size: 100)),
            ),
          ],
          child: EditBookingPage(bookingId: bookingId!),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.adminSelectVendor,
      builder: (context, state) {
        final args = state.extra;
        if (args is! SelectVendorArgs) {
          return _buildSessionExpiredFallback(context);
        }
        return SelectVendorScreen(args: args);
      },
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
        final extra = state.extra;
        return BlocProvider(
          create: (_) => getIt<EventTypeBloc>(),
          child: CreateEventTypePage(
            id: id,
            initialData: extra is EventTypeListItem ? extra : null,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.adminDecorations,
      builder: (context, state) => const AdminDecorationsPage(),
    ),
    GoRoute(
      path: AppRoutes.adminVendors,
      builder: (context, state) => const AdminVendorsPage(),
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
          final currentAuthState = authCubit.state;
          Future.delayed(const Duration(milliseconds: 350), () {
            if (!context.mounted) return;
            if (currentAuthState is AuthAuthenticated) {
              final pending = LoginRedirectData.pending;
              if (pending != null) {
                LoginRedirectData.pending = null;
                GoRouter.of(
                  context,
                ).go(pending.nextRoute, extra: pending.extra);
              } else {
                final role = (currentAuthState as AuthAuthenticated).user.role;
                final isAdmin = role.toUpperCase() == 'ADMIN';
                GoRouter.of(
                  context,
                ).go(isAdmin ? AppRoutes.adminDashboard : AppRoutes.splash);
              }
            } else if (currentAuthState is! AuthLoading) {
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
      path: AppRoutes.selectEventDate,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final args = state.extra;
        if (args is! BookingArgs) {
          if (id.isEmpty) return _buildSessionExpiredFallback(context);
          return BookingPage(decorationId: id);
        }
        return SelectEventDatePage(args: args);
      },
    ),
    GoRoute(
      path: AppRoutes.paymentMethod,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final args = state.extra;
        if (args is! BookingArgs) {
          if (id.isEmpty) return _buildSessionExpiredFallback(context);
          return BookingPage(decorationId: id);
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
        final extras = state.extra as Map<String, dynamic>?;
        if (extras == null) return _buildSessionExpiredFallback(context);
        return BookingSuccessPage(
          bookingId: extras['bookingId'] ?? '',
          amount: extras['amount'] ?? '',
          date: extras['date'] ?? '',
          time: extras['time'],
        );
      },
    ),
    GoRoute(
      path: '/booking/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        if (id.isEmpty) return _buildSessionExpiredFallback(context);
        return BookingPage(decorationId: id);
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
      path: '${AppRoutes.adminDecorationsDetail}/:id',
      builder: (context, state) {
        final decorationId =
            state.pathParameters['id'] ?? state.extra as String? ?? '';
        return DecorationDetailPage(decorationId: decorationId);
      },
    ),

    GoRoute(
      path: '${AppRoutes.editDeceoration}/:id',
      builder: (context, state) {
        final decorationId =
            state.pathParameters['id'] ?? state.extra as String? ?? '';
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  getIt<CreateDecorationBloc>()
                    ..add(const LoadEventTypesAndCities()),
            ),
            BlocProvider(
              create: (_) =>
                  getIt<DecorationDetailBloc>()
                    ..add(LoadDecorationDetail(decorationId)),
            ),
            BlocProvider(create: (_) => getIt<UpdateDecorationBloc>()),
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
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => BlocProvider(
        create: (context) => getIt<ProfileBloc>()..add(GetProfileEvent()),
        child: const CompleteProfilePage(),
      ),
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

    final hasNoCity = cityState is CityInitial;
    if (hasNoCity && !isCitySelection) {
      return AppRoutes.citySelection;
    }

    if (authState is AuthLoading) {
      return null;
    }

    if (isOtp &&
        authState is! AuthAuthenticated &&
        state.extra is! OtpScreenArgs) {
      return AppRoutes.login;
    }

    if (authState is AuthUnauthenticated) {
      if (isPublic || isLogin || isOtp) return null;
      if (location.startsWith('/admin') ||
          location == AppRoutes.booking ||
          location.startsWith('/booking/') ||
          location == AppRoutes.myBookings ||
          location.startsWith('${AppRoutes.myBookings}/')) {
        return AppRoutes.splash;
      }
      return null;
    }

    if (authState is AuthAuthenticated) {
      final role = authState.user.role;
      final isAdmin = role.toUpperCase() == 'ADMIN';

      if (isOtp) {
        final pending = LoginRedirectData.pending;
        if (pending != null) {
          LoginRedirectData.pending = null;
          return pending.nextRoute;
        }
        return isAdmin ? AppRoutes.adminDashboard : AppRoutes.splash;
      }

      if (isLogin) {
        return isAdmin ? AppRoutes.adminDashboard : AppRoutes.splash;
      }

      if (location.startsWith('/admin') && !isAdmin) {
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
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
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
                  onPressed: () => context.go(AppRoutes.splash),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
