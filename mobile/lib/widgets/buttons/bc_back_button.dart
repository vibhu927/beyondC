import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/theme/app_colors.dart';

class BCBackButton extends StatelessWidget {
  const BCBackButton({
    super.key,
    required this.onPressed,
    this.icon = Symbols.arrow_back_rounded,
    this.iconColor = AppColors.white,
    this.backgroundColor = AppColors.darkSurface,
    this.borderColor = AppColors.darkBorder,
    this.borderWidth = 1.5,
    this.iconSize = 20,
    this.buttonSize = 40,
    this.tooltip = 'Back',
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double iconSize;
  final double buttonSize;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: iconColor,
        size: iconSize,
      ),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        side: borderWidth > 0
            ? BorderSide(color: borderColor, width: borderWidth)
            : BorderSide.none,
        fixedSize: Size.square(buttonSize),
        padding: EdgeInsets.zero,
      ),
      tooltip: tooltip,
    );
  }
}
