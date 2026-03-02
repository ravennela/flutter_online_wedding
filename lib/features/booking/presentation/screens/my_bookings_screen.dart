import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../bloc/booking_bloc.dart';
import '../../bloc/booking_event.dart';
import '../../bloc/booking_state.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myBookings),
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const LoadingWidget();
          } else if (state is BookingError) {
            return ErrorWidget(message: state.message);
          } else if (state is BookingsLoaded) {
            if (state.bookings.isEmpty) {
              return const Center(
                child: Text('No bookings found'),
              );
            }
            return ListView.builder(
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return ListTile(
                  title: Text('Booking #${booking.bookingId}'),
                  subtitle: Text('Status: ${booking.status}'),
                  trailing: Text('\$${booking.totalAmount.toStringAsFixed(2)}'),
                  onTap: () {
                    // Navigate to booking detail
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
