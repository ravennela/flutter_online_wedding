import 'package:flutter/material.dart';
import 'package:flutter_online/core/routes/app_router_config.dart';
import 'package:flutter_online/core/theme/app_theme.dart';

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Meeveduka',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
