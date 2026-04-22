import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_shadows.dart';

class BCPrimaryButton extends StatefulWidget { 
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final List<BoxShadow> shadow;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const BCPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor = AppColors.neon,
    this.textColor = AppColors.ink,
    this.shadow = const [],
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  // Named constructors for common variants
  factory BCPrimaryButton.neon(
      {required String label,
      VoidCallback? onPressed,
      bool isLoading = false,
      bool isFullWidth = true}) {
    return BCPrimaryButton(
        label: label,
        onPressed: onPressed,
        backgroundColor: AppColors.neon,
        textColor: AppColors.ink,
        shadow: AppShadows.ink,
        isLoading: isLoading,
        isFullWidth: isFullWidth);
  }

  factory BCPrimaryButton.pink(
      {required String label,
      VoidCallback? onPressed,
      bool isLoading = false,
      bool isFullWidth = true}) {
    return BCPrimaryButton(
        label: label,
        onPressed: onPressed,
        backgroundColor: AppColors.pink,
        textColor: AppColors.white,
        shadow: AppShadows.ink,
        isLoading: isLoading,
        isFullWidth: isFullWidth);
  }

  factory BCPrimaryButton.dark(
      {required String label,
      VoidCallback? onPressed,
      bool isLoading = false,
      bool isFullWidth = true}) {
    return BCPrimaryButton(
        label: label,
        onPressed: onPressed,
        backgroundColor: AppColors.ink,
        textColor: AppColors.neon,
        shadow: AppShadows.neon,
        isLoading: isLoading,
        isFullWidth: isFullWidth);
  }

  @override
  State<BCPrimaryButton> createState() => _BCPrimaryButtonState();
}

class _BCPrimaryButtonState extends State<BCPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final resolvedShadow =
        widget.shadow.isEmpty ? AppShadows.softTight(context) : widget.shadow;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: widget.onPressed == null
              ? AppColors.muted
              : widget.backgroundColor,
          border:
              Border.all(color: AppColors.ink, width: AppSpacing.borderWidth),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          boxShadow: _isPressed ? AppShadows.pressed : resolvedShadow,
        ),
        transform: _isPressed
            ? Matrix4.translationValues(
                AppSpacing.shadowOffset, AppSpacing.shadowOffset, 0)
            : Matrix4.identity(),
        child: widget.isLoading
            ? Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: widget.textColor,
                  ),
                ),
              )
            : Row(
                mainAxisSize:
                    widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.prefixIcon != null) ...[
                    widget.prefixIcon!,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    widget.label,
                    style: AppTypography.buttonLG
                        .copyWith(color: widget.textColor),
                  ),
                  if (widget.suffixIcon != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    widget.suffixIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}
