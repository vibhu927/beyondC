import 'package:flutter/material.dart';

import '../../../core/theme/app_shadows.dart';

class HomeContentSheet extends StatelessWidget {
  const HomeContentSheet({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(32)),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.2 : 0.28,
    );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.scaffoldBackgroundColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? dividerColor,
          width: 1,
        ),
        boxShadow: boxShadow ?? AppShadows.soft(context),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
