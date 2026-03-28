import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_online/features/profile/presentation/bloc/profile_event.dart';
import 'admin_profile_popup.dart';

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileBloc>()..add(GetProfileEvent()),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            // Global Search
            Container(
              width: 400,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search bookings, vendors, customers...",
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(bottom: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Notifications
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_outlined),
                  color: Colors.grey.shade600,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Profile
            const AdminProfilePopup(isMobile: false),
          ],
        ),
      ),
    );
  }
}
