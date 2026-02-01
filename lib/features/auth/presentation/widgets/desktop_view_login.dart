
import 'package:flutter/material.dart';
import 'package:flutter_online/features/auth/presentation/widgets/shared_login_screen.dart';

class WebLoginView extends StatelessWidget {
  const WebLoginView();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Soft background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFF7EB),
                Color(0xFFFFFBF6),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        Center(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                LoginCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
