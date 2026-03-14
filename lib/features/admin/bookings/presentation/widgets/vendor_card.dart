import 'package:flutter/material.dart';
import 'package:flutter_online/features/admin/vendors/domain/entities/vendor_entity.dart';

class VendorCard extends StatelessWidget {
  final VendorEntity vendor;
  final String bookingCategory;
  final VoidCallback onAssign;
  final VoidCallback onDeAssign;

  final bool isAssigned;

  const VendorCard({
    super.key,
    required this.vendor,
    required this.bookingCategory,
    required this.onAssign,
    required this.onDeAssign,
    this.isAssigned = false,
  });

  @override
  Widget build(BuildContext context) {
    final String vendorName = vendor.companyName.isEmpty ? (vendor.name ?? 'Unknown Vendor') : vendor.companyName;
    // In the admin panel, we allow all vendors to be assignable for now.
    // The previous check compared ServiceType (e.g. DECORATION) with EventType (e.g. Marriage),
    // which caused vendors to appear 'Not Applicable' incorrectly.
    final bool categoryMatches = true; 
    
    // For now, since we're just integrating the list, we don't have assignment status from the entity
    // We might need to extend VendorEntity or handle this differently later.
    final bool isAwaitingResponse = false; 
    final bool isAccepted = false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Badge
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=800&auto=format&fit=crop', // Placeholder
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: vendor.active ? const Color(0xFF22C55E) : const Color(0xFF64748B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vendor.active ? 'AVAILABLE' : 'NOT AVAILABLE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        vendorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF97316), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${vendor.rating}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${vendor.serviceType} · ${vendor.city ?? "Remote"}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  vendor.description ?? 'No description provided.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                if (isAccepted)
                   _buildStatusLabel('Vendor Accepted', Colors.green)
                else if (isAwaitingResponse)
                  Column(
                    children: [
                      _buildStatusLabel('Assigned – Awaiting Vendor Response', Colors.blue),
                      const SizedBox(height: 12),
                      _buildButton(
                        'De-Assign Vendor',
                        onDeAssign,
                        isPrimary: false,
                        color: Colors.red,
                      ),
                    ],
                  )
                else if (isAssigned)
                   Column(
                    children: [
                      _buildStatusLabel('Vendor Assigned', Colors.green),
                      const SizedBox(height: 12),
                      _buildButton(
                        'De-Assign Vendor',
                        onDeAssign,
                        isPrimary: false,
                        color: Colors.red,
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton('Assign Vendor', onAssign, isPrimary: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildButton('Profile', () {}, isPrimary: false),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(String text, Color bgColor, {Color? textColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? bgColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap, {required bool isPrimary, Color? color}) {
    final primaryColor = color ?? const Color(0xFFF97316);
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? primaryColor : primaryColor.withOpacity(0.1),
          foregroundColor: isPrimary ? Colors.white : primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}
