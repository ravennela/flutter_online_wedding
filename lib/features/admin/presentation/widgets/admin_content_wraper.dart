import 'package:flutter/material.dart';

class AdminContentWrapper extends StatelessWidget {
  final Widget child;

  const AdminContentWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1400, // Web-safe max width
        ),
        child: child,
      ),
    );
  }
}
