import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AmbientGlow extends StatelessWidget {
  const AmbientGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.7,
              spreadRadius: size * 0.08,
            ),
          ],
        ),
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 28,
    this.backgroundColor,
    this.accentColor = AppColors.blue,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? backgroundColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withValues(alpha: 0.9),
            border: uniformBorder(accentColor),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: neoShadows(accentColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  const GlassButton({
    required this.label,
    required this.accent,
    required this.onTap,
    this.textColor,
  });

  final String label;
  final Color accent;
  final VoidCallback? onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: accent.withValues(
                alpha: accent == AppColors.ink ? 0.08 : 0.16,
              ),
              border: uniformBorder(
                accent,
                width: 0.95,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              boxShadow: neoShadows(
                accent,
                alpha: 0.18,
                offset: 3,
                blurRadius: 10,
              ),
            ),
            child: Text(
              label,
              style: AppTypography.labelSM.copyWith(
                color: textColor ?? (accent == AppColors.neon ? AppColors.ink : accent),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InlineTonePill extends StatelessWidget {
  const InlineTonePill({
    required this.label,
    required this.accent,
    this.onDark = false,
  });

  final String label;
  final Color accent;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: onDark ? 0.24 : 0.12),
          border: uniformBorder(
            accent,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: neoShadows(
            accent,
            alpha: onDark ? 0.14 : 0.1,
            offset: 2.5,
            blurRadius: 8,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelXS.copyWith(
            color: onDark ? AppColors.white : AppColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

Border uniformBorder(
  Color accent, {
  double width = 1.5,
}) {
  return Border.all(
    color: accent.withValues(alpha: 0.4),
    width: width,
  );
}

List<BoxShadow> neoShadows(
  Color accent, {
  double alpha = 0.16,
  double offset = 4,
  double blurRadius = 14,
}) {
  return [
    BoxShadow(
      color: accent.withValues(alpha: alpha),
      offset: Offset(offset, offset),
      blurRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: blurRadius,
      offset: const Offset(0, 10),
    ),
  ];
}
