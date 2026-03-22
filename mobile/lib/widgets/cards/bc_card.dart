import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class BCCard extends StatelessWidget {
  final Widget child;
  final List<BoxShadow> shadow;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const BCCard({
    super.key,
    required this.child,
    this.shadow = const [],
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.borderRadius = AppSpacing.radiusLG,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.lightBg);
    final bdColor =
        borderColor ?? (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: bdColor, width: AppSpacing.borderWidth),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadow,
        ),
        child: child,
      ),
    );
  }
}
