import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/brand_provider.dart';
import '../../../providers/saved_creators_provider.dart';

class CreatorDetailBottomSheet extends ConsumerWidget {
  const CreatorDetailBottomSheet({
    super.key,
    required this.creator,
  });

  final CreatorPreview creator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avgPrice = creator.avgCollabPrice ?? creator.startingPrice;
    final stars = _starsForCreator(creator);
    final savedCreators = ref.watch(savedCreatorsProvider);
    final isSaved = savedCreators.valueOrNull?.any((s) => s.creatorId == creator.id) ?? false;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.lightBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.huge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          border:
                              Border.all(color: AppColors.brandPrimary, width: 3),
                        ),
                        alignment: Alignment.center,
                        child: (creator.avatarUrl ?? '').trim().isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  creator.avatarUrl!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Text(
                                    creator.initials,
                                    style: AppTypography.labelLG.copyWith(
                                      color: AppColors.brandPrimary,
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                creator.initials,
                                style: AppTypography.labelLG.copyWith(
                                  color: AppColors.brandPrimary,
                                ),
                              ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              creator.firstName,
                              style: AppTypography.displaySM.copyWith(
                                color: AppColors.brandDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            _Pill(
                              label: creator.tier,
                              tone: AppColors.brandDark.withValues(alpha: 0.08),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.lightBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _stat(
                            'Followers',
                            Formatters.followerCount(creator.followersCount)
                                .toLowerCase(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _stat(
                            'Engagement',
                            '${creator.engagementRate.toStringAsFixed(1)}%',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _stat('Avg Price', Formatters.currency(avgPrice)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: creator.niches
                        .map(
                          (niche) => _Pill(
                            label: niche,
                            tone: AppColors.brandDark.withValues(alpha: 0.08),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: creator.contentTypes
                        .map(
                          (type) => _Pill(
                            label: type,
                            tone: AppColors.brandPrimary.withValues(alpha: 0.45),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Past Collabs: ${creator.pastCollabs ?? 0}  |  $stars',
                    style: AppTypography.labelMD.copyWith(
                      fontFamily: 'SpaceGrotesk',
                    ),
                  ),
                  if (creator.portfolioLinks.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: creator.portfolioLinks
                          .map(
                            (link) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusFull),
                                border: Border.all(
                                  color: AppColors.brandDark.withValues(alpha: 0.16),
                                ),
                              ),
                              child: Text(link, style: AppTypography.labelSM),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Full name and handle revealed after match.',
                    style: AppTypography.bodySM.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GestureDetector(
                    onTap: () => ref.read(savedCreatorsProvider.notifier).toggleSave(creator.id),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isSaved ? AppColors.brandPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(
                          color: isSaved ? AppColors.brandDark : AppColors.brandDark.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSaved ? Symbols.bookmark_rounded : Symbols.bookmark_border_rounded,
                            size: 20,
                            color: AppColors.brandDark,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            isSaved ? 'Saved' : 'Save Creator',
                            style: AppTypography.labelSM.copyWith(
                              color: AppColors.brandDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _BrandPillButton(
                    label: 'View Full Profile',
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(
                        RouteNames.partnerProfile,
                        extra: {
                          'id': creator.id,
                          'first_name': creator.firstName,
                          'full_name': creator.firstName,
                          'name': creator.firstName,
                          'avatar_url': creator.avatarUrl,
                          'avatarUrl': creator.avatarUrl,
                          'role': 'creator',
                          'viewerRole': 'brand',
                          'tier': creator.tier,
                          'bio': creator.niches.join(', '),
                          'followers': creator.followersCount,
                          'readOnly': true,
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _BrandPillButton(
                    label: 'Send Request',
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final confirmed = await _showCreditConfirmDialog(
                        context,
                        title: 'Send request to ${creator.firstName}?',
                        subtitle:
                            '1 credit will be deducted only if the creator accepts.',
                      );
                      if (!confirmed || !context.mounted) return;

                      final ok = await ref.read(brandProvider.notifier).sendDirectRequest(
                            creatorId: creator.id,
                            creatorName: creator.firstName,
                          );

                      if (!context.mounted) return;
                      if (!ok) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Could not send request.')),
                        );
                        return;
                      }

                      Navigator.of(context).pop();
                      messenger.showSnackBar(
                        SnackBar(content: Text('Request sent to ${creator.firstName}.')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodyXS.copyWith(color: AppColors.muted)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.labelSM.copyWith(
            color: AppColors.brandDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

Future<bool> _showCreditConfirmDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xl,
        ),
        content: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.displaySM.copyWith(
                  color: AppColors.brandDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: AppTypography.bodySM.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _DialogPillButton(
                      label: 'Cancel',
                      backgroundColor: AppColors.white,
                      textColor: AppColors.brandDark,
                      borderColor: AppColors.brandDark.withValues(alpha: 0.2),
                      onTap: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _DialogPillButton(
                      label: 'Confirm',
                      backgroundColor: AppColors.brandDark,
                      textColor: AppColors.white,
                      borderColor: AppColors.brandDark,
                      onTap: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return confirmed ?? false;
}

String _starsForCreator(CreatorPreview creator) {
  final rating = (3.8 + (creator.engagementRate / 10)).clamp(1.0, 5.0);
  final count = rating.round().clamp(1, 5);
  return List.filled(count, '*').join();
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.tone,
  });

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: AppTypography.labelXS.copyWith(
          color: AppColors.brandDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BrandPillButton extends StatelessWidget {
  const _BrandPillButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.brandDark,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSM.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogPillButton extends StatelessWidget {
  const _DialogPillButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSM.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
