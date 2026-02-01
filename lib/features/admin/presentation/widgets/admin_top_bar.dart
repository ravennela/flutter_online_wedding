import 'package:flutter/material.dart';

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                // const CircleAvatar(
                //   radius: 16,
                //   backgroundImage: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?fit=crop&w=150&h=150'), 
                //   onBackgroundImageError: (_, __) {},
                // ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Alex Johnson",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
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
            ),
          ),
        ],
      ),
    );
  }
}
