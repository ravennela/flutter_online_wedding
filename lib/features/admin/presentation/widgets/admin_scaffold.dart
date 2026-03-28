import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/admin/presentation/widgets/admin_profile_popup.dart';
import 'package:flutter_online/features/admin/presentation/widgets/admin_sidebar.dart';
import 'package:flutter_online/features/admin/presentation/widgets/admin_top_bar.dart';
import 'package:flutter_online/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_online/features/profile/presentation/bloc/profile_event.dart';

class AdminScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final String title;
  final Widget? floatingActionButton;

  const AdminScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.title,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    // Breakpoint: 1000px matches what we want for tablet/desktop split
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             AdminSidebar(initialIndex: selectedIndex, isMobile: false),
             Expanded(
              child: Column(
                children: [
                  const AdminTopBar(),
                  Expanded(
                    child: body,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1A1F36),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1F36)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade100,
            height: 1,
          ),
        ),
        actions: [
          BlocProvider(
            create: (context) => getIt<ProfileBloc>()..add(GetProfileEvent()),
            child: const AdminProfilePopup(isMobile: true),
          ),
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.notifications_none_outlined),
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        elevation: 16,
        width: 250, 
        child: AdminSidebar(initialIndex: selectedIndex, isMobile: true),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
