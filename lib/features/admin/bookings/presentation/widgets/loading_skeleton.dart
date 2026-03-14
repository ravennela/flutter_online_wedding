import 'package:flutter/material.dart';

class LoadingSkeleton extends StatelessWidget {
  final double? height;
  final double? width;
  final double borderRadius;
  final Color? color;

  const LoadingSkeleton({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 8.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class BookingListSkeleton extends StatelessWidget {
  const BookingListSkeleton({super.key});

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
      children: List.generate(4, (index) => const Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: LoadingSkeleton(height: 120, borderRadius: 16),
        ),
      )),
    );
  }

  Widget _buildFilterSkeleton() {
    return const LoadingSkeleton(height: 60, borderRadius: 12);
  }

  Widget _buildListSkeleton() {
    return Column(
      children: List.generate(5, (index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LoadingSkeleton(height: 80, borderRadius: 12),
      )),
    );
  }
}
