import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_online/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_online/features/profile/presentation/bloc/profile_state.dart';

class AdminProfilePopup extends StatelessWidget {
  final bool isMobile;
  const AdminProfilePopup({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String name = "Loading...";
        String email = "-";
        String phone = "-";
        String city = "-";

        if (state is ProfileLoaded) {
          name = state.profile.name.isEmpty ? "-" : state.profile.name;
          email = state.profile.email.isEmpty ? "-" : state.profile.email;
          phone = state.profile.phone.isEmpty ? "-" : state.profile.phone;
          city = (state.profile.city == null || state.profile.city!.isEmpty) ? "-" : state.profile.city!;
        } else if (state is ProfileError) {
          name = "Error";
        }

        return PopupMenuButton<void>(
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tooltip: "Profile Info",
          position: PopupMenuPosition.under,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 6),
            decoration: isMobile ? null : BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle, size: 28, color: Color(0xFF1A1F36)),
                if (!isMobile) ...[
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
                      ),
                      Text(
                        "Admin",
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
                ],
              ],
            ),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfoRow(Icons.person, "Name", name),
                  _buildProfileInfoRow(Icons.email, "Email", email),
                  _buildProfileInfoRow(Icons.phone, "Phone", phone),
                  _buildProfileInfoRow(Icons.location_on, "City", city),
                  const Divider(),
                  TextButton.icon(
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout, size: 18, color: Colors.red),
                    label: const Text("Logout", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1F36), fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
