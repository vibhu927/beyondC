import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class BCAppLoader extends StatefulWidget {
  const BCAppLoader({
    super.key,
    this.tips = _defaultTips,
  });

  final List<String> tips;

  static const List<String> _defaultTips = <String>[
    'Tip: Keep your profile complete to boost trust and faster approvals.',
    'Tip: Quick replies improve your collab close rate significantly.',
    'Tip: Clear deliverables avoid confusion and reduce revisions.',
    'Tip: Post regularly to keep discovery ranking healthy.',
    'Tip: Use focused niches to attract better-fit partners.',
  ];

  @override
  State<BCAppLoader> createState() => _BCAppLoaderState();
}

class _BCAppLoaderState extends State<BCAppLoader> {
  Timer? _tipTimer;
  int _tipIndex = 0;

  @override
  void initState() {
    super.initState();
    _tipTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (!mounted || widget.tips.isEmpty) return;
      setState(() {
        _tipIndex = (_tipIndex + 1) % widget.tips.length;
      });
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tip = widget.tips.isEmpty
        ? 'Loading your BeyondC workspace...'
        : widget.tips[_tipIndex];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(color: AppColors.ink, width: 2),
          ),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              tip,
              key: ValueKey<String>(tip),
              textAlign: TextAlign.center,
              style: AppTypography.bodySM.copyWith(color: AppColors.ink),
            ),
          ),
        ),
      ],
    );
  }
}

class BCLoadingOverlay extends StatelessWidget {
  const BCLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
  });

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.68),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: const BCAppLoader(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
