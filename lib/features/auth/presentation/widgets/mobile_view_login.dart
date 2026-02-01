
import 'package:flutter/material.dart';
import 'package:flutter_online/features/auth/presentation/widgets/shared_login_screen.dart';
import 'package:go_router/go_router.dart';

class MobileLoginView extends StatelessWidget {
  const MobileLoginView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            const SizedBox(height: 32),
            const LoginCard(),
          ],
        ),
      ),
    );
  }
}
