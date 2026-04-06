import 'package:flutter/material.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentRose.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title.toUpperCase(),
              style: AppTextStyles.labelL.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: Text(
              subtitle!,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
