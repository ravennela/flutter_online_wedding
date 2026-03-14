import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../bloc/admin_booking_detail_bloc.dart';
import '../../models/admin_booking_ui_model.dart';
import '../../models/vendor_model.dart';
import 'status_badge.dart';

class VendorSection extends StatelessWidget {
  final List<VendorModel> vendors;
  final AdminBookingUIModel booking;

  const VendorSection({
    super.key, 
    required this.vendors,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Assigned Vendors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${vendors.length}',
              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (vendors.isEmpty)
          _buildEmptyVendors()
        else
          ...vendors.map((vendor) => _buildVendorCard(context, vendor)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () async {
              final result = await context.push(
                AppRoutes.adminSelectVendor,
                extra: SelectVendorArgs(
                  bookingId: booking.id,
                  bookingCode: booking.bookingCode,
                  eventCategory: booking.eventType,
                  city: booking.city,
                  assignedVendorId: booking.vendorId,
                ),
              );
              
              if (result == true && context.mounted) {
                // Trigger refresh in detail bloc
                context.read<AdminBookingDetailBloc>().add(FetchBookingDetail(booking.id));
              }
            },
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Assign New Vendor'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyVendors() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.person_off_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No vendors assigned yet', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context, VendorModel vendor) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.indigo.shade50,
              backgroundImage: vendor.avatarUrl != null ? NetworkImage(vendor.avatarUrl!) : null,
              child: vendor.avatarUrl == null 
                  ? Icon(Icons.person, color: Colors.indigo.shade300, size: 20) 
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(vendor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(vendor.category, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            if (vendor.id.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                onPressed: () => _showDeAssignConfirmation(context, vendor),
                tooltip: 'De-assign Vendor',
              ),
            StatusBadge(
              label: vendor.status,
              color: vendor.status.toUpperCase() == 'ACTIVE' ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeAssignConfirmation(BuildContext context, VendorModel vendor) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text('De-Assign Vendor'),
        content: Text('Are you sure you want to de-assign "${vendor.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(innerContext);
              context.read<AdminBookingDetailBloc>().add(
                DeAssignVendor(booking.id, vendor.id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('De-Assign'),
          ),
        ],
      ),
    );
  }
}
