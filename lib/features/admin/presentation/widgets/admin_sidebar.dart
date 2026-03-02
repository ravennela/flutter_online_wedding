import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/routes/app_routes.dart';

class AdminSidebar extends StatefulWidget {
  final int initialIndex;
  final bool isMobile;
  const AdminSidebar({super.key, this.initialIndex = 0, this.isMobile = false});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  late int _selectedIndex;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _isExpanded = !widget.isMobile; // Always expanded if not mobile (default), but actually if isMobile we want it expanded too? 
    // Wait, typically sidebar on desktop is expanded by default. On mobile drawer it MUST be expanded.
    _isExpanded = true;
  }

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
    {'icon': Icons.calendar_today_outlined, 'label': 'Bookings'},
    {'icon': Icons.event_available_outlined, 'label': 'Events'},
    {'icon': Icons.local_florist_outlined, 'label': 'Decorations'},
    {'icon': Icons.storefront_outlined, 'label': 'Vendors'},
    {'icon': Icons.payment_outlined, 'label': 'Payments'},
    {'icon': Icons.star_border_outlined, 'label': 'Reviews'},
    {'icon': Icons.settings_outlined, 'label': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isExpanded ? 250 : 70,
      color: Colors.white,
      child: Column(
        children: [
          // Logo
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerLeft,
             child: Row(
              children: [
                InkWell(
                  onTap: widget.isMobile ? null : () => setState(() => _isExpanded = !_isExpanded),
                  child: Icon(Icons.widgets, color: Colors.blue.shade700, size: 28)
                ),
                if (_isExpanded) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "EventAdmin",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F36),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = index == _selectedIndex;
                
                return _SidebarItem(
                  icon: item['icon'],
                  label: item['label'],
                  isSelected: isSelected,
                  isExpanded: _isExpanded,
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    if (item['label'] == 'Events') {
                      context.go(AppRoutes.adminEventTypes);
                    } else if (item['label'] == 'Dashboard') {
                      context.go(AppRoutes.adminDashboard);
                    } else if (item['label'] == 'Decorations') {
                      context.go(AppRoutes.adminDecorations);
                    } else if (item['label'] == 'Bookings') {
                      context.go(AppRoutes.adminBookings);
                    }
                  },
                );
              },
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: _SidebarItem(
                   icon: Icons.logout,
                   label: "Logout",
                   isSelected: false,
                   isExpanded: _isExpanded,
                   onTap: () {
                     context.read<AuthCubit>().logout();
                   },
                   isDanger: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool isDanger;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Colors.blue.shade700;
    final activeBg = Colors.blue.shade50;
    final textStyle = TextStyle(
      color: isDanger ? Colors.red : (isSelected ? activeColor : Colors.grey.shade600),
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      fontSize: 14,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              size: 20, 
              color: isDanger ? Colors.red : (isSelected ? activeColor : Colors.grey.shade600)
            ),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis)),
            ],
          ],
        ),
      ),
    );
  }
}
