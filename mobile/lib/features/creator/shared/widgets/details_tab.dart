import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable container for profile details tabs.
///
/// This file previously contained an incomplete private implementation that
/// referenced symbols from another file, which caused analyzer errors.
class DetailsTab extends StatelessWidget {
  const DetailsTab({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.screenPadding,
      AppSpacing.lg,
      AppSpacing.screenPadding,
      AppSpacing.xxxl,
    ),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      children: children,
    );
  }
}

class DetailsTabPlaceholder extends StatelessWidget {
  const DetailsTabPlaceholder({super.key, this.message = 'Details coming soon'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodySM,
        ),
      ),
    );
  }
}
