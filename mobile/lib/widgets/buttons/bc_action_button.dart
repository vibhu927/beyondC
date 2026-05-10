import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_shadows.dart';

class BCActionButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isFullWidth;

  const BCActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isFullWidth = false,
  });

  @override
  State<BCActionButton> createState() => _BCActionButtonState();
}

class _BCActionButtonState extends State<BCActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.isFullWidth ? double.infinity : MediaQuery.of(context).size.width * 0.5,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: widget.onPressed == null ? AppColors.muted : AppColors.agencyDark,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.agencyDark, width: AppSpacing.borderWidth),
          boxShadow: _isPressed ? AppShadows.pressed : AppShadows.ink,
        ),
        transform: _isPressed
            ? Matrix4.translationValues(AppSpacing.shadowOffset, AppSpacing.shadowOffset, 0)
            : Matrix4.identity(),
        child: Center(
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: AppTypography.labelMD.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
