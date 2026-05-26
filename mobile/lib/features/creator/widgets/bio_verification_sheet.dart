import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/creator_provider.dart';
import '../shared/widgets/creator_design_system.dart';

enum _BioPhase { enterUsername, showCode, verifying, error, done }

Future<void> openBioVerificationSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _BioVerificationSheetBody(ref: ref);
    },
  );
}

class _BioVerificationSheetBody extends ConsumerStatefulWidget {
  const _BioVerificationSheetBody({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_BioVerificationSheetBody> createState() =>
      _BioVerificationSheetBodyState();
}

class _BioVerificationSheetBodyState
    extends ConsumerState<_BioVerificationSheetBody> {
  _BioPhase _phase = _BioPhase.enterUsername;
  final _usernameController = TextEditingController();
  String _verificationCode = '';
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _generateCode() async {
    final username = _usernameController.text.trim().replaceAll('@', '');
    if (username.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your Instagram username.';
        _phase = _BioPhase.error;
      });
      return;
    }

    setState(() => _phase = _BioPhase.verifying);

    try {
      final code = await ref.read(creatorActionsProvider.notifier).generateBioCode();
      if (!mounted) return;
      setState(() {
        _verificationCode = code;
        _phase = _BioPhase.showCode;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _phase = _BioPhase.error;
      });
    }
  }

  Future<void> _verify() async {
    final username = _usernameController.text.trim().replaceAll('@', '');
    setState(() => _phase = _BioPhase.verifying);

    try {
      final result = await ref.read(creatorActionsProvider.notifier).verifyBioCode(username);
      if (!mounted) return;

      final verified = result['verified'] as bool? ?? false;
      if (verified) {
        setState(() => _phase = _BioPhase.done);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = result['error'] as String? ?? 'Verification failed. Please try again.';
          _phase = _BioPhase.error;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _phase = _BioPhase.error;
      });
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _verificationCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied to clipboard!'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _phase == _BioPhase.showCode ? 0.72 : 0.58,
      minChildSize: 0.5,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: AppColors.creatorDark.withValues(alpha: 0.16),
              width: 1.2,
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom,
            ),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Bio Verification',
                      style: AppTypography.displaySM.copyWith(
                        color: AppColors.creatorDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.creatorDark.withValues(alpha: 0.16),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppColors.creatorDark,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_phase == _BioPhase.enterUsername)
                _buildEnterUsername()
              else if (_phase == _BioPhase.showCode)
                _buildShowCode()
              else if (_phase == _BioPhase.verifying)
                _buildVerifying()
              else if (_phase == _BioPhase.error)
                _buildError()
              else if (_phase == _BioPhase.done)
                _buildDone(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnterUsername() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your Instagram username',
          style: AppTypography.labelMD.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.creatorDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              hintText: '@username',
              border: InputBorder.none,
              hintStyle: TextStyle(color: AppColors.muted),
            ),
            style: AppTypography.bodyMD.copyWith(color: AppColors.creatorDark),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _generateCode(),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Symbols.warning_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Make sure your Instagram account is set to public before starting.',
                  style: AppTypography.bodyXS.copyWith(
                    color: AppColors.creatorDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        GlassButton(
          label: 'Generate Code',
          accent: AppColors.creatorDark,
          onTap: _generateCode,
        ),
      ],
    );
  }

  Widget _buildShowCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your verification code',
          style: AppTypography.labelMD.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.creatorDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassPanel(
          accentColor: AppColors.neon,
          radius: 16,
          backgroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _verificationCode,
                  style: AppTypography.displaySM.copyWith(
                    color: AppColors.creatorDark,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _copyCode,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.creatorDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Symbols.content_copy_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Follow these steps:',
          style: AppTypography.labelMD.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.creatorDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _StepItem(number: 1, text: 'Open the Instagram app'),
        const _StepItem(number: 2, text: 'Go to your profile'),
        const _StepItem(number: 3, text: 'Tap "Edit profile"'),
        const _StepItem(
          number: 4,
          text: 'Paste the code above in your bio',
        ),
        const _StepItem(number: 5, text: 'Tap "Done" to save'),
        const _StepItem(number: 6, text: 'Come back here and tap "Verify"'),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Symbols.warning_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Your Instagram account must be public for verification to work.',
                  style: AppTypography.bodyXS.copyWith(
                    color: AppColors.creatorDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        GlassButton(
          label: "I've Done This — Verify",
          accent: AppColors.neon,
          solidBackground: true,
          textColor: AppColors.ink,
          onTap: _verify,
        ),
      ],
    );
  }

  Widget _buildVerifying() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            color: AppColors.creatorDark,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Verifying your Instagram...',
          style: AppTypography.labelMD.copyWith(
            color: AppColors.creatorDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'This may take a few seconds.',
          style: AppTypography.bodySM.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Symbols.error_outline_rounded,
                color: AppColors.error,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  _errorMessage,
                  style: AppTypography.bodySM.copyWith(
                    color: AppColors.creatorDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: GlassButton(
                label: 'Try Again',
                accent: AppColors.creatorDark,
                onTap: () {
                  setState(() {
                    _phase = _verificationCode.isEmpty
                        ? _BioPhase.enterUsername
                        : _BioPhase.showCode;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDone() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Symbols.check_circle_rounded,
            color: AppColors.success,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Verified!',
          style: AppTypography.displaySM.copyWith(
            color: AppColors.creatorDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your Instagram account has been verified.',
          style: AppTypography.bodySM.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.text,
  });

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.creatorDark,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: AppTypography.labelSM.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySM.copyWith(
                color: AppColors.creatorDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
