import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'bc_app_loader.dart';
import 'buttons/bc_primary_button.dart';

class BCErrorState extends StatefulWidget {
  const BCErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String message;
  final FutureOr<void> Function()? onRetry;
  final String retryLabel;

  @override
  State<BCErrorState> createState() => _BCErrorStateState();
}

class _BCErrorStateState extends State<BCErrorState> {
  bool _isRetrying = false;
  String? _lastLoggedMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _logErrorIfNeeded();
  }

  @override
  void didUpdateWidget(covariant BCErrorState oldWidget) {
    super.didUpdateWidget(oldWidget);
    _logErrorIfNeeded();
  }

  void _logErrorIfNeeded() {
    if (_lastLoggedMessage == widget.message) return;
    _lastLoggedMessage = widget.message;
    debugPrint('BCErrorState captured exception: ${widget.message}');
  }

  Future<void> _handleRetry() async {
    if (_isRetrying || widget.onRetry == null) return;

    setState(() => _isRetrying = true);
    try {
      await Future.sync(() => widget.onRetry!.call());
    } catch (error, stackTrace) {
      debugPrint('BCErrorState retry failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isRetrying) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: BCAppLoader(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('😵', style: TextStyle(fontSize: 42)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Well, that escalated quickly. BeyondC tripped over its own sneakers.\nWe are fixing it behind the scenes, please try again.',
                      style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.onRetry != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      BCPrimaryButton.dark(
                        label: widget.retryLabel,
                        onPressed: _handleRetry,
                        isFullWidth: false,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
