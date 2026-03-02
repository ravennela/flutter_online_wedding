
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';

class LoginCard extends StatelessWidget {
  const LoginCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF2D9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.diamond,
              color: Color(0xFFD4A017),
              size: 30,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'LuxeEvents',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'EXPERIENCE ELEGANCE',
            style: TextStyle(fontSize: 12, letterSpacing: 2, color: Colors.grey),
          ),

          const SizedBox(height: 28),

          const Text(
            'Enter your mobile number to begin.',
            style: TextStyle(fontSize: 15),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          // Phone input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: const [
                Text('+91',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '98765 43210',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'A 6-digit code will be sent via SMS for verification.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                context.push(AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A017),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Send OTP',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 28),

          const Divider(),
          const SizedBox(height: 12),

          const Text(
            'MEMBER OF LUXE GLOBAL',
            style: TextStyle(fontSize: 11, letterSpacing: 2, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
