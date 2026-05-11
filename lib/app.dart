import 'package:flutter/material.dart';
import 'package:flutter_online/core/routes/app_router_config.dart';
import 'package:flutter_online/core/theme/app_theme.dart';
import 'package:flutter_online/presentation/widgets/whatsapp_floating_button.dart';

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Meeveduka',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            // Wrap in an Overlay to support Tooltips outside the main Navigator
            Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => const WhatsAppFloatingButton(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
