import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/bc_error_state.dart';
import '../widgets/bid_bottom_sheet.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  const CampaignDetailScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  ConsumerState<CampaignDetailScreen> createState() =>
      _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen> {
  Future<void> _openBidSheet(Campaign campaign) async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BidBottomSheet(campaign: campaign),
    );

    if (!mounted || submitted != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bid submitted successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final campaignAsync = ref.watch(campaignDetailProvider(widget.id));
    final bids = ref.watch(myBidsProvider).valueOrNull ?? const <Bid>[];

    if (campaignAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    }

    if (campaignAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Campaign Detail')),
        body: BCErrorState(
          message: campaignAsync.error.toString(),
          onRetry: () => ref.invalidate(campaignDetailProvider(widget.id)),
        ),
      );
    }

    final campaign = campaignAsync.value;
    if (campaign == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Campaign Detail')),
        body: Center(
          child: Text(
            'Campaign not found',
            style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
          ),
        ),
      );
    }

    final activeBid = bids
        .where(
            (bid) => bid.campaignId == campaign.id && bid.status != 'withdrawn')
        .cast<Bid?>()
        .firstOrNull;
    final hasBid = activeBid != null;
    final daysLeft = campaign.deadline.difference(DateTime.now()).inDays;
    const slotCount = 3;
    final filledSlots = (campaign.bidCount / 9).ceil().clamp(1, slotCount);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
            ),
            title: const Text(
              'Campaign Detail',
              style: AppTypography.displaySM,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share link copied.')),
                  );
                },
                icon: const Icon(Icons.share_rounded, color: AppColors.ink),
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: AppColors.divider),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                AppSpacing.huge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BCCard(
                    shadow: AppShadows.pink,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: _avatarColor(campaign.brandInitial),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.ink,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                campaign.brandInitial,
                                style: AppTypography.labelLG
                                    .copyWith(color: AppColors.white),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Brand in ${campaign.brandCategory}',
                                    style: AppTypography.labelLG,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      BCBadge(
                                        label:
                                            _collabLabel(campaign.collabType),
                                        variant:
                                            _collabVariant(campaign.collabType),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      BCBadge(
                                        label:
                                            _deadlineLabel(campaign.deadline),
                                        variant: BCBadgeVariant.outline,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          campaign.createdAt == null
                              ? 'Recently posted'
                              : 'Posted ${Formatters.timeAgo(campaign.createdAt!)}',
                          style: AppTypography.bodyXS,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    '${Formatters.currency(campaign.minBudget)}–${Formatters.currency(campaign.maxBudget)}',
                    style: AppTypography.displayLG,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  BCBadge(
                    label: _collabLabel(campaign.collabType),
                    variant: _collabVariant(campaign.collabType),
                  ),
                  if (campaign.collabType != CampaignCollabType.paid) ...[
                    const SizedBox(height: AppSpacing.md),
                    BCCard(
                      shadow: AppShadows.purple,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product details',
                            style: AppTypography.labelLG,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Brand will send a curated product package for authentic usage-based content.',
                            style: AppTypography.bodySM.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Estimated value: ${Formatters.currency((campaign.minBudget + campaign.maxBudget) ~/ 2)}',
                            style: AppTypography.labelSM,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  const Text('Deliverables 📋', style: AppTypography.displaySM),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: campaign.deliverables
                        .map(
                          (item) => BCBadge(
                            label: item,
                            variant: BCBadgeVariant.outline,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Keep tone native to your page. Focus on clear hooks and product storytelling in the first 3 seconds.',
                    style:
                        AppTypography.bodySM.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text('Looking for', style: AppTypography.displaySM),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      BCBadge(
                        label: _targetTier(campaign),
                        variant: BCBadgeVariant.outline,
                      ),
                      BCBadge(
                        label: campaign.brandCategory,
                        variant: BCBadgeVariant.outline,
                      ),
                      BCBadge(
                        label: _minFollowers(campaign),
                        variant: BCBadgeVariant.outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      BCBadge(
                        label: '${campaign.bidCount} creators have bid',
                        variant: BCBadgeVariant.neon,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      BCBadge(
                        label: '${daysLeft.clamp(0, 365)} days left',
                        variant: BCBadgeVariant.pink,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.ink, width: 1.5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: filledSlots / slotCount,
                        child: const ColoredBox(color: AppColors.neon),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$filledSlots of $slotCount slots filled',
                    style: AppTypography.bodyXS,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: hasBid
              ? Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '✅ You\'ve already bid on this',
                        style: AppTypography.labelMD,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          await ref
                              .read(creatorActionsProvider.notifier)
                              .withdrawBid(activeBid.id);
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Could not withdraw bid.')),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.ink, width: 2),
                        foregroundColor: AppColors.ink,
                      ),
                      child: const Text('Withdraw Bid'),
                    ),
                  ],
                )
              : BCPrimaryButton.neon(
                  label: 'Place Your Bid →',
                  onPressed: () => _openBidSheet(campaign),
                ),
        ),
      ),
    );
  }
}

String _collabLabel(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return 'Paid';
    case CampaignCollabType.barter:
      return 'Barter';
    case CampaignCollabType.hybrid:
      return 'Hybrid';
  }
}

BCBadgeVariant _collabVariant(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return BCBadgeVariant.pink;
    case CampaignCollabType.barter:
      return BCBadgeVariant.blue;
    case CampaignCollabType.hybrid:
      return BCBadgeVariant.purple;
  }
}

String _deadlineLabel(DateTime deadline) {
  final duration = deadline.difference(DateTime.now());
  if (duration.isNegative) return 'Ended';
  if (duration.inDays > 0) return '${duration.inDays}d left';
  if (duration.inHours > 0) return '${duration.inHours}h left';
  return '${duration.inMinutes.clamp(1, 59)}m left';
}

Color _avatarColor(String initial) {
  const palette = [
    AppColors.pink,
    AppColors.blue,
    AppColors.purple,
    AppColors.orange,
  ];
  return palette[initial.codeUnitAt(0) % palette.length];
}

String _targetTier(Campaign campaign) {
  if (campaign.maxBudget >= 500000) return 'Micro · Mid creators';
  if (campaign.maxBudget >= 250000) return 'Nano · Micro creators';
  return 'Nano creators';
}

String _minFollowers(Campaign campaign) {
  if (campaign.maxBudget >= 500000) return 'Min 50K followers';
  if (campaign.maxBudget >= 250000) return 'Min 10K followers';
  return 'Min 5K followers';
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
