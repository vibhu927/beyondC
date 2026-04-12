import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class ArchiveTile extends StatelessWidget {
  const ArchiveTile({super.key, required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.darkBorder, width: 1.4),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          color: AppColors.surface,
        ),
        child: Row(
          children: [
            const Icon(Symbols.archive_rounded, color: AppColors.ink),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Text(
                'Archived chats',
                style: AppTypography.labelMD,
              ),
            ),
            Text(
              '$count',
              style: AppTypography.labelMD.copyWith(color: AppColors.muted),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Symbols.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
