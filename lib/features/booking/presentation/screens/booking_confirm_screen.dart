import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../bloc/booking_bloc.dart';
import '../../bloc/booking_state.dart';

class BookingConfirmScreen extends StatelessWidget {
  final String bookingId;
  
  const BookingConfirmScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.bookingConfirm),
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingConfirmed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking confirmed successfully')),
            );
            Navigator.of(context).pop();
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingLoading) {
            return const LoadingWidget();
          } else if (state is BookingError) {
            return ErrorWidget(message: state.message);
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Confirm your booking?'),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Confirm Booking',
                  onPressed: () {
                    // Handle confirmation
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
