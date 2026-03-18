import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class BCEmptyState extends StatelessWidget {
  const BCEmptyState({
    super.key,
    required this.message,
    this.emoji = '📭',
  });

  final String message;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Center(
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
