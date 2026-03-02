import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  // --- Actions ---
  void _onSendOtp() {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
        ),
      );
      return;
    }
    context.read<AuthCubit>().sendOtp(_phoneController.text);
    // Navigate to OTP Verification (Placeholder logic)
    // context.pushNamed('otp_verification', extra: _phoneController.text);
    // For now purely UI as requested
    // Navigate to OTP Verification
    //context.push(AppRoutes.otp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0), // Luxury Champagne/Beige
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  // --- Desktop Layout ---
  Widget _buildDesktopLayout() {
    return Stack(
      children: [
        // Background
        Positioned.fill(child: Container(color: const Color(0xFFF9F6F0))),

        // Floating Back Button
        Positioned(
          top: 40,
          left: 40,
          child: _BackButton(onTap: () => context.pop()),
        ),

        // Centered Card
        Center(
          child: Container(
            width: 440,
            constraints: const BoxConstraints(maxHeight: 900),
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC79A2B).withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
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

  // --- Mobile Layout ---
  Widget _buildMobileLayout() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 16),
              child: _BackButton(onTap: () => context.pop()),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                children: [
                  const SizedBox(height: 20),
                  _LoginFormContent(
                    controller: _phoneController,
                    onSendOtp: _onSendOtp,
                    redirectData: widget.redirectData,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Common Components ---

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
    const goldColor = Color(0xFFC79A2B); // Rich Gold

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Icon Badge
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF8E8), // Soft Gold BG
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.diamond_outlined, color: goldColor, size: 32),
          ),
        ),

        const SizedBox(height: 32),

        // 2. Branding
        const Text(
          "LuxeEvents",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1F36),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "EXPERIENCE ELEGANCE",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 2.0,
          ),
        ),

        const SizedBox(height: 48),

        // 3. Instruction
        Text(
          "Enter your mobile number to begin.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 24),

        // 4. Input Field
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Row(
            children: [
              Text(
                "+91",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: Color(0xFF1A1F36),
                  ),
                  decoration: InputDecoration(
                    hintText: "98765 43210",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w400,
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

        const SizedBox(height: 16),

        // 5. Helper Text
        Text(
          "A 6-digit code will be sent via SMS for verification.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),

        const SizedBox(height: 32),

        // 6. Action Button
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onSendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: goldColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  "Send OTP",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 48),

        // 7. Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FooterLink(text: "TERMS OF SERVICE"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.circle, size: 4, color: Colors.grey.shade300),
            ),
            _FooterLink(text: "PRIVACY POLICY"),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "MEMBER OF LUXE GLOBAL",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade300,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade200)),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Icon(Icons.arrow_back, size: 20, color: Colors.grey.shade800),
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
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade400,
        letterSpacing: 0.5,
      ),
    );
  }
}
