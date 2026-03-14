import 'package:flutter/material.dart';

class VendorSkeletonCard extends StatelessWidget {
  const VendorSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                    Container(height: 16, width: 150, color: const Color(0xFFF1F5F9)),
                    Container(height: 16, width: 40, color: const Color(0xFFF1F5F9)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(height: 12, width: 200, color: const Color(0xFFF1F5F9)),
                const SizedBox(height: 16),
                Container(height: 12, width: double.infinity, color: const Color(0xFFF1F5F9)),
                const SizedBox(height: 4),
                Container(height: 12, width: double.infinity, color: const Color(0xFFF1F5F9)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Container(height: 40, color: const Color(0xFFF1F5F9))),
                    const SizedBox(width: 12),
                    Expanded(child: Container(height: 40, color: const Color(0xFFF1F5F9))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
