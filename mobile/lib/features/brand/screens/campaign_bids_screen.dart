import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../widgets/bid_review_card.dart';

enum _BidSort { newest, priceAsc, priceDesc, bestMatch }

class CampaignBidsScreen extends ConsumerStatefulWidget {
  const CampaignBidsScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  ConsumerState<CampaignBidsScreen> createState() => _CampaignBidsScreenState();
}

class _CampaignBidsScreenState extends ConsumerState<CampaignBidsScreen> {
  _BidSort _activeSort = _BidSort.newest;
  final Set<String> _passedBidIds = <String>{};

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(brandProvider.notifier).fetchBrandHome();
      if (!mounted) return;
      await ref.read(brandProvider.notifier).fetchCampaignBids(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final brandState = ref.watch(brandProvider);
    final campaign = ref.read(brandProvider.notifier).campaignById(widget.id);

    if (campaign == null && brandState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    }

    if (campaign == null) {
      return const Scaffold(
        body: Center(child: Text('Campaign not found')),
      );
    }

    final allBids = ref.read(brandProvider.notifier).bidsForCampaign(widget.id);
    final bids = _applySort(allBids)
        .where((bid) => !_passedBidIds.contains(bid.id))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: AppSpacing.screenPadding,
        title: Row(
          children: [
            Expanded(
              child: Text(
                campaign.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.displaySM,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            BCBadge(
              label: '${bids.length} bids',
              variant: BCBadgeVariant.pink,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.lg,
          AppSpacing.screenPadding,
          AppSpacing.huge,
        ),
        children: [
          BCCard(
            shadow: AppShadows.pink,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_inr(campaign.minBudget)} - ${_inr(campaign.maxBudget)}',
                  style: AppTypography.displaySM,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${_collabLabel(campaign.collabType)}  •  Deadline ${DateFormat('d MMM').format(campaign.deadline ?? DateTime.now())}',
                  style: AppTypography.bodySM.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      border: Border.all(color: AppColors.ink, width: 1.5),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: campaign.slotsTotal == 0
                          ? 0
                          : campaign.slotsFilled / campaign.slotsTotal,
                      child: const ColoredBox(color: AppColors.neon),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${campaign.slotsFilled} of ${campaign.slotsTotal} slots filled',
                  style: AppTypography.bodyXS,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Sort', style: AppTypography.labelMD),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _sortPill('Newest', _activeSort == _BidSort.newest, () {
                  setState(() => _activeSort = _BidSort.newest);
                }),
                const SizedBox(width: AppSpacing.sm),
                _sortPill('Price ↑', _activeSort == _BidSort.priceAsc, () {
                  setState(() => _activeSort = _BidSort.priceAsc);
                }),
                const SizedBox(width: AppSpacing.sm),
                _sortPill('Price ↓', _activeSort == _BidSort.priceDesc, () {
                  setState(() => _activeSort = _BidSort.priceDesc);
                }),
                const SizedBox(width: AppSpacing.sm),
                _sortPill('Best Match', _activeSort == _BidSort.bestMatch, () {
                  setState(() => _activeSort = _BidSort.bestMatch);
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (brandState.isBidsLoading)
            const _BidSkeletonList()
          else if (bids.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
              child: Text(
                'No bids yet for this campaign.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
              ),
            )
          else
            Column(
              children: [
                for (var index = 0; index < bids.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: BidReviewCard(
                      bid: bids[index],
                      shadow: index.isEven ? AppShadows.neon : AppShadows.pink,
                      onAccept: () => _onAcceptBid(bids[index]),
                      onPass: () =>
                          setState(() => _passedBidIds.add(bids[index].id)),
                      onReadMore: (bids[index].pitch ?? '').trim().isEmpty
                          ? null
                          : () => _showPitchDialog(bids[index]),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _onAcceptBid(CampaignBid bid) async {
    final confirmed = await _showNeoConfirmDialog(
      context,
      title: 'Accept this bid?',
      subtitle: '1 credit will be deducted.',
      confirmLabel: 'Accept',
    );

    if (!confirmed || !mounted) return;

    final ok = await ref.read(brandProvider.notifier).acceptBid(
          campaignId: widget.id,
          bidId: bid.id,
        );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to accept bid. Check credits.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 Matched! Full details now unlocked.')),
    );
  }

  Future<void> _showPitchDialog(CampaignBid bid) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: BCCard(
            shadow: AppShadows.ink,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pitch from ${bid.creatorFirstName}',
                    style: AppTypography.displaySM),
                const SizedBox(height: AppSpacing.sm),
                Text(bid.pitch ?? '-', style: AppTypography.bodyMD),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: BCPrimaryButton.neon(
                    label: 'Close',
                    isFullWidth: false,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<CampaignBid> _applySort(List<CampaignBid> bids) {
    final sorted = [...bids];
    switch (_activeSort) {
      case _BidSort.newest:
        sorted.sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
      case _BidSort.priceAsc:
        sorted.sort((a, b) => a.amount.compareTo(b.amount));
      case _BidSort.priceDesc:
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
      case _BidSort.bestMatch:
        sorted.sort((a, b) {
          final scoreA = (a.engagementRate * 1000).round();
          final scoreB = (b.engagementRate * 1000).round();
          return scoreB.compareTo(scoreA);
        });
    }
    return sorted;
  }

  Widget _sortPill(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: active ? AppColors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _BidSkeletonList extends StatelessWidget {
  const _BidSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : AppColors.lightDivider,
            highlightColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurfaceAlt
                : AppColors.lightSurfaceAlt,
            child: BCCard(
              child: Column(
                children: [
                  Container(height: 18, color: AppColors.white),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 18, color: AppColors.white),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 44, color: AppColors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> _showNeoConfirmDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: BCCard(
          shadow: AppShadows.ink,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.displaySM),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: AppTypography.bodySM.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: AppColors.ink, width: 2),
                        minimumSize: const Size.fromHeight(46),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: BCPrimaryButton.neon(
                      label: confirmLabel,
                      onPressed: () => Navigator.of(dialogContext).pop(true),
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

  return result ?? false;
}

String _inr(int value) =>
    '₹${NumberFormat.decimalPattern('en_IN').format(value)}';

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
