import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

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
    // Log OTP Submitted
    String otp = _controllers.map((e) => e.text).join();
    debugPrint("OTP Submitted: $otp");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP Submitted')),
    );
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
        Positioned.fill(
          child: Container(color: const Color(0xFFF9F6F0)),
        ),
        
        // Floating Back Button
        Positioned(
          top: 40,
          left: 40,
          child: _BackButton(
            onTap: () => context.go(AppRoutes.login),
          ),
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
              child: _OtpFormContent(
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
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 16),
              child: _BackButton(
                onTap: () => context.go(AppRoutes.login),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: _OtpFormContent(
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
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final int timerValue;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const _OtpFormContent({
    required this.controllers,
    required this.focusNodes,
    required this.timerValue,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFC79A2B); // Rich Gold // From Login Screen
    const blueColor = Color(0xFF4285F4); // Google Blue, but matching design somewhat
    // The design shows a blue button, let's stick to the Login Screen's gold theme for consistency 
    // unless strictly asked to match the blue image. 
    // "Match the attached OTP designs exactly (visual style, spacing, typography, colors)"
    // The design images show:
    // Image 1: Blue button (Verify & Continue), Blue text (Resend OTP).
    // Image 2: Blue button (Verify & Continue).
    // Okay, I will use the Blue color from the design images where appropriate, but maybe keep some gold accents if it makes sense?
    // Actually, "Do NOT redesign or change UI style." suggests I should follow the image colors.
    // The image has a very specific blue: #1A73E8 or similar.
    final primaryColor = const Color(0xFF1A73E8); 

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Lock Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Icon(Icons.lock_person_outlined, color: primaryColor, size: 32),
          ),
        ),
        
        const SizedBox(height: 32),

        // 2. Title
        const Text(
          "Verify OTP",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1F36),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        
        // 3. Subtitle
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
              fontFamily: 'Roboto', // Default flutter font, but explicit
            ),
            children: [
              const TextSpan(text: "We’ve sent a 6-digit code to "),
              TextSpan(
                text: "+91 XXXXXXXX12",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // 4. OTP Inputs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 50, // Slightly large for desktop, but fits mobile
              height: 56,
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                autofocus: index == 0,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                     // Handle backspace logic if needed differently, but standard behavior usually works
                     // To properly handle backspace on empty, we might need RawKeyboardListener, but simple is requested.
                     focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),

        const SizedBox(height: 40),

        // 5. Action Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Verify & Continue",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 6. Resend Timer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn’t receive the code? ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            GestureDetector(
              onTap: timerValue == 0 ? onResend : null,
              child: Text(
                timerValue > 0
                    ? "Resend in 00:${timerValue.toString().padLeft(2, '0')}"
                    : "Resend OTP",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: timerValue == 0 ? primaryColor : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
        
        // Footer spacing
        const SizedBox(height: 32),
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
          // No shadow in one design, slight shadow in other. Using subtle.
          border: Border.all(color: Colors.white), // distinct from background if any
        ),
        child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
      ),
    );
  }
}
