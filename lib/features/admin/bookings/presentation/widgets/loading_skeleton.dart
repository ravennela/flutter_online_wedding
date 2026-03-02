import 'package:flutter/material.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatsSkeleton(),
        const SizedBox(height: 32),
        _buildFilterSkeleton(),
        const SizedBox(height: 24),
        _buildListSkeleton(),
      ],
    );
  }

  Widget _buildStatsSkeleton() {
    return Row(
      children: List.generate(4, (index) => Expanded(
        child: Container(
          height: 120,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      )),
    );
  }

  Widget _buildFilterSkeleton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildListSkeleton() {
    return Column(
      children: List.generate(5, (index) => Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
      )),
    );
  }
}
