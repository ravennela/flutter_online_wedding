import 'package:flutter/material.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
import 'package:flutter_online/shared/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

class BookingSuccessPage extends StatelessWidget {
  final String bookingId;
  final String amount;
  final String date;
  final String? time;

  const BookingSuccessPage({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.date,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    final dateTimeDisplay = time != null ? '$date at $time' : date;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.accentRose.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.celebration_outlined,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Experience Reserved!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingXL,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Meeveduka experience is now scheduled for $dateTimeDisplay. Our specialists will begin crafting your celebration shortly.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyL.copyWith(color: AppColors.textSecondary, height: 1.6),
                  ),
                  const SizedBox(height: 64),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.divider),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _SuccessDetailRow(label: 'Booking ID', value: '#$bookingId'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(height: 1, color: AppColors.divider),
                        ),
                        _SuccessDetailRow(label: 'Investment', value: amount),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(height: 1, color: AppColors.divider),
                        ),
                        _SuccessDetailRow(
                          label: 'Status',
                          value: 'CONFIRMED',
                          isTag: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),
                  PrimaryButton(
                    text: 'RETURN TO EXPLORE',
                    onPressed: () => context.go('/'),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.push('/bookings'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(
                      'VIEW MY RESERVATIONS',
                      style: AppTextStyles.labelM.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTag;

  const _SuccessDetailRow({
    required this.label,
    required this.value,
    this.isTag = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        if (isTag)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentRose.withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: AppTextStyles.labelS.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          )
        else
          Text(
            value,
            style: AppTextStyles.headingS.copyWith(fontSize: 16),
          ),
      ],
    );
  }
}
