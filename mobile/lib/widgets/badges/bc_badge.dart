import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

enum BCBadgeVariant {
  neon,
  pink,
  blue,
  purple,
  orange,
  success,
  error,
  warning,
  dark,
  outline
}

class BCBadge extends StatelessWidget {
  final String label;
  final BCBadgeVariant variant;
  final String? prefixEmoji;

  const BCBadge({
    super.key,
    required this.label,
    this.variant = BCBadgeVariant.neon,
    this.prefixEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getColors(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        boxShadow: AppShadows.softTight(context),
        border: variant == BCBadgeVariant.outline
            ? Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixEmoji != null) ...[
            Text(prefixEmoji!, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelXS.copyWith(color: colors.$2),
          ),
        ],
      ),
    );
  }

  (Color, Color) _getColors(bool isDark) {
    return switch (variant) {
      BCBadgeVariant.neon => (AppColors.neon, AppColors.ink),
      BCBadgeVariant.pink => (AppColors.pink, AppColors.white),
      BCBadgeVariant.blue => (AppColors.blue, AppColors.white),
      BCBadgeVariant.purple => (AppColors.purple, AppColors.white),
      BCBadgeVariant.orange => (AppColors.orange, AppColors.white),
      BCBadgeVariant.success => (AppColors.success, AppColors.white),
      BCBadgeVariant.error => (AppColors.error, AppColors.white),
      BCBadgeVariant.warning => (AppColors.warning, AppColors.ink),
      BCBadgeVariant.dark => (AppColors.ink, AppColors.white),
      BCBadgeVariant.outline => (
          isDark ? AppColors.darkSurface : AppColors.lightSurface,
          isDark ? AppColors.darkText : AppColors.lightText,
        ),
    };
  }
}
