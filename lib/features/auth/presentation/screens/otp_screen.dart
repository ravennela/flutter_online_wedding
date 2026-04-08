import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/auth/domain/models/otp_screen_args.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_online/features/auth/presentation/utils/auth_helpers.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OtpScreen extends StatefulWidget {
  final OtpScreenArgs args;

  const OtpScreen({super.key, required this.args});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _start = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void _onVerify() {
    final otp = _controllers.map((e) => e.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 6-digit OTP')),
      );
      return;
    }
    context.read<AuthCubit>().verifyOtp(widget.args.phone, otp);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          onLoginSuccess(
            context,
            widget.args.redirectData,
            userRole: state.user.role,
          );
        }

        if (state is AuthError) {
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
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 768) {
              return _buildDesktopLayout();
            }
            return _buildMobileLayout();
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Container(color: AppColors.background),
        ),
        
        // Floating Back Button
        Positioned(
          top: 40,
          left: 40,
          child: _BackButton(
            onTap: () => context.pop(),
          ),
        ),

        // Centered Card
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
              child: _OtpFormContent(
                phone: widget.args.phone,
                controllers: _controllers,
                focusNodes: _focusNodes,
                timerValue: _start,
                onVerify: _onVerify,
                onResend: () {},
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout() {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 16),
              child: _BackButton(
                onTap: () => context.pop(),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: _OtpFormContent(
                    phone: widget.args.phone,
                    controllers: _controllers,
                    focusNodes: _focusNodes,
                    timerValue: _start,
                    onVerify: _onVerify,
                    onResend: () {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Common Components ---

class _OtpFormContent extends StatelessWidget {
  final String phone;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final int timerValue;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const _OtpFormContent({
    required this.phone,
    required this.controllers,
    required this.focusNodes,
    required this.timerValue,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primaryDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.accentRose.withOpacity(0.55),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Center(
            child: Icon(
              Icons.lock_person_outlined,
              color: accent,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Verify OTP',
          style: AppTextStyles.headingXL.copyWith(
            fontSize: 28,
            fontStyle: FontStyle.normal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Meeveduka',
          style: AppTextStyles.labelM.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.bodyM.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: "We've sent a 6-digit code to "),
              TextSpan(
                text:
                    "+91 ${phone.length >= 8 ? '******${phone.substring(phone.length - 2)}' : phone}",
                style: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 48,
              height: 54,
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                autofocus: index == 0,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: AppTextStyles.headingXL.copyWith(fontSize: 22),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surfaceMuted,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accent, width: 2),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(
              'VERIFY & CONTINUE',
              style: AppTextStyles.buttonPrimary.copyWith(fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the code? ",
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: timerValue == 0 ? onResend : null,
              child: Text(
                timerValue > 0
                    ? 'Resend in 00:${timerValue.toString().padLeft(2, '0')}'
                    : 'Resend OTP',
                style: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w700,
                  color: timerValue == 0 ? accent : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
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
