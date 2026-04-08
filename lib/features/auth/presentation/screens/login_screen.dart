import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
import 'package:flutter_online/features/auth/domain/models/login_redirect_data.dart';
import 'package:flutter_online/features/auth/domain/models/otp_screen_args.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_state.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  /// Optional redirect data when user came from a protected action.
  final LoginRedirectData? redirectData;

  const LoginScreen({super.key, this.redirectData});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onSendOtp() {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid 10-digit mobile number',
            style: AppTextStyles.bodyM.copyWith(color: AppColors.onPrimary),
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    context.read<AuthCubit>().sendOtp(_phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return _buildDesktopLayout();
          }
          return _buildMobileLayout();
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: AppColors.background)),
        Positioned(
          top: 40,
          left: 40,
          child: _BackButton(onTap: () => context.pop()),
        ),
        Center(
          child: Container(
            width: 440,
            constraints: const BoxConstraints(maxHeight: 900),
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: _LoginFormContent(
                controller: _phoneController,
                onSendOtp: _onSendOtp,
                redirectData: widget.redirectData,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 12),
              child: _BackButton(onTap: () => context.pop()),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  const SizedBox(height: 12),
                  _LoginFormContent(
                    controller: _phoneController,
                    onSendOtp: _onSendOtp,
                    redirectData: widget.redirectData,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginFormContent extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendOtp;
  final LoginRedirectData? redirectData;

  const _LoginFormContent({
    required this.controller,
    required this.onSendOtp,
    this.redirectData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.accentRose.withOpacity(0.55),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.favorite_border_rounded,
              color: AppColors.primaryDark,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Meeveduka',
          style: AppTextStyles.displaySerif.copyWith(
            fontSize: 32,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'SIGN IN TO CONTINUE',
          style: AppTextStyles.labelM.copyWith(
            color: AppColors.primary,
            letterSpacing: 2.4,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Enter your mobile number to begin.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyL.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Text(
                '+91',
                style: AppTextStyles.bodyL.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                width: 1,
                height: 26,
                color: AppColors.divider,
                margin: const EdgeInsets.symmetric(horizontal: 14),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: AppTextStyles.bodyL.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '98765 43210',
                    hintStyle: AppTextStyles.bodyM.copyWith(
                      color: AppColors.textHint,
                      letterSpacing: 0.6,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'A 6-digit code will be sent via SMS for verification.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyS.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),
        BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is OtpSent) {
              context.push(
                AppRoutes.otp,
                extra: OtpScreenArgs(
                  phone: state.phone,
                  redirectData: redirectData,
                ),
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            }
            return SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onSendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shadowColor: AppColors.primary.withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  'SEND OTP',
                  style: AppTextStyles.buttonPrimary.copyWith(fontSize: 13),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FooterLink(text: 'TERMS OF SERVICE'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.circle, size: 4, color: AppColors.divider),
            ),
            _FooterLink(text: 'PRIVACY POLICY'),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.divider)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'MEEVEDUKA',
                style: AppTextStyles.labelS.copyWith(
                  color: AppColors.textHint,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.divider)),
          ],
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  const _FooterLink({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelS.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}
