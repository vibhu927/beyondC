import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/services/instagram_oauth_service.dart';
import '../../../providers/creator_provider.dart';
import '../shared/widgets/creator_design_system.dart';
import 'bio_verification_sheet.dart';

Future<bool> openInstagramConnectSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _InstagramConnectSheetBody(ref: ref);
    },
  ).then((result) => result ?? false);
}

class _InstagramConnectSheetBody extends ConsumerStatefulWidget {
  const _InstagramConnectSheetBody({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_InstagramConnectSheetBody> createState() =>
      _InstagramConnectSheetBodyState();
}

class _InstagramConnectSheetBodyState
    extends ConsumerState<_InstagramConnectSheetBody> {
  bool _isConnecting = false;

  Future<void> _connectViaLogin() async {
    if (_isConnecting) return;
    setState(() => _isConnecting = true);

    try {
      final oauthService = ref.read(instagramOAuthServiceProvider);
      final result = await oauthService.connectInstagram();

      if (!mounted) return;

      if (result.isSuccess) {
        await ref.read(creatorHomeProvider.notifier).refreshSilently();
        if (!mounted) return;
        ref.invalidate(creatorProfileProvider);
        Navigator.of(context).pop(true);
      } else {
        setState(() => _isConnecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Instagram connection failed. Please try again.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isConnecting = false);
      final message =
          ref.read(instagramOAuthServiceProvider).extractApiError(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.isEmpty ? 'Instagram connection failed.' : message),
        ),
      );
    }
  }

  void _connectViaBio() {
    Navigator.of(context).pop();
    openBioVerificationSheet(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.5,
      maxChildSize: 0.65,
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              AppSpacing.xl,
            ),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Connect Instagram',
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
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppColors.creatorDark,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _OptionCard(
                icon: Symbols.photo_camera_front_rounded,
                title: 'Login Authentication',
                description:
                    'Log in with Instagram to securely verify your account and auto-fetch your stats.',
                accentColor: AppColors.pink,
                buttonLabel: _isConnecting ? 'Connecting...' : 'Connect via Login',
                onTap: _isConnecting ? null : _connectViaLogin,
              ),
              const SizedBox(height: AppSpacing.md),
              _OptionCard(
                icon: Symbols.edit_note_rounded,
                title: 'Bio Authentication',
                description:
                    'Add a code to your Instagram bio to prove ownership. Requires a public account.',
                accentColor: AppColors.creatorDark,
                buttonLabel: 'Connect via Bio',
                onTap: _connectViaBio,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.buttonLabel,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final String buttonLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accentColor: accentColor,
      radius: 22,
      backgroundColor: AppColors.white.withValues(alpha: 0.88),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelMD.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.creatorDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodySM.copyWith(
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassButton(
            label: buttonLabel,
            accent: accentColor,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
