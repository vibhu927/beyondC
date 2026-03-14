import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class BCCard extends StatelessWidget {
  final Widget child;
  final List<BoxShadow> shadow;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const BCCard({
    super.key,
    required this.child,
    this.shadow = const [],
    this.backgroundColor = AppColors.white,
    this.borderColor = AppColors.ink,
    this.padding,
    this.borderRadius = AppSpacing.radiusLG,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: AppSpacing.borderWidth),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadow,
        ),
        child: child,
      ),
    );
  }
}
