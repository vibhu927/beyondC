import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../chat/profile_view_sheet.dart';
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
      await ref.read(brandProvider.notifier).fetchBrandHome(force: true);
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
        body: Center(child: CircularProgressIndicator(color: AppColors.brandPrimary)),
      );
    }

    if (campaign == null) {
      return Scaffold(
        backgroundColor: AppColors.lightBg,
        appBar: AppBar(
          backgroundColor: AppColors.lightBg,
          elevation: 0,
          foregroundColor: AppColors.brandDark,
          title: const Text('Campaign Bids', style: AppTypography.displaySM),
        ),
        body: const Center(child: Text('Campaign not found')),
      );
    }

    final allBids = ref.read(brandProvider.notifier).bidsForCampaign(widget.id);
    final creatorsById = {
      for (final creator in brandState.creators) creator.id: creator,
    };

    final acceptedBids = _applySort(
      allBids
          .where((bid) => bid.isAccepted || bid.status.trim().toLowerCase() == 'accepted')
          .toList(growable: false),
    );

    final pendingBids = _applySort(
      allBids
          .where((bid) => bid.status.trim().toLowerCase() == 'pending')
          .toList(growable: false),
    ).where((bid) => !_passedBidIds.contains(bid.id)).toList(growable: false);

    final effectiveSlotsFilled = acceptedBids.length > campaign.slotsFilled
        ? acceptedBids.length
        : campaign.slotsFilled;
    final hasSlotsLeft = effectiveSlotsFilled < campaign.slotsTotal;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(decoration: BoxDecoration(color: AppColors.lightBg)),
            ),
            Positioned(
              top: -46,
              right: -32,
              child: _GlowOrb(size: 136, color: AppColors.brandPrimary.withValues(alpha: 0.08)),
            ),
            Positioned(
              top: 220,
              left: -44,
              child: _GlowOrb(size: 112, color: AppColors.brandDark.withValues(alpha: 0.08)),
            ),
            ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                MediaQuery.of(context).padding.top + 14,
                AppSpacing.screenPadding,
                AppSpacing.huge,
              ),
              children: [
                const _BackHeader(),
                const SizedBox(height: AppSpacing.md),
                _ScreenTitleBar(
                  title: campaign.title,
                  bidCount: pendingBids.length,
                ),
                const SizedBox(height: AppSpacing.md),
                _CampaignOverviewCard(
                  campaign: campaign,
                  effectiveSlotsFilled: effectiveSlotsFilled,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (acceptedBids.isNotEmpty) ...[
                  const Text('Accepted Creators', style: AppTypography.labelMD),
                  const SizedBox(height: AppSpacing.sm),
                  Column(
                    children: [
                      for (var index = 0; index < acceptedBids.length; index++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: (() {
                            final bid = acceptedBids[index];
                            final creator = creatorsById[bid.creatorId];
                            return BidReviewCard(
                              bid: bid,
                              shadow: const [
                                BoxShadow(
                                  color: AppColors.brandPrimaryGlassShadow,
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                              displayName: bid.creatorFullName,
                              avatarUrl: (bid.creatorAvatarUrl ?? '').trim().isNotEmpty
                                  ? bid.creatorAvatarUrl
                                  : creator?.avatarUrl,
                              onAccept: null,
                              onPass: null,
                              onAvatarTap: () => _openCreatorProfile(
                                bid,
                                displayName: bid.creatorFullName,
                                avatarUrl: (bid.creatorAvatarUrl ?? '').trim().isNotEmpty
                                    ? bid.creatorAvatarUrl
                                    : creator?.avatarUrl,
                              ),
                              onReadMore: (bid.pitch ?? '').trim().isEmpty
                                  ? null
                                  : () => _showPitchDialog(bid),
                              footer: _ActionPillButton(
                                label: 'Cancel Collab',
                                onPressed: () => _onCancelCollab(bid),
                              ),
                            );
                          })(),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (hasSlotsLeft) ...[
                  const Text('New Bids', style: AppTypography.labelMD),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _SortPill(
                          label: 'Newest',
                          active: _activeSort == _BidSort.newest,
                          onTap: () => setState(() => _activeSort = _BidSort.newest),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _SortPill(
                          label: 'Price Low',
                          active: _activeSort == _BidSort.priceAsc,
                          onTap: () => setState(() => _activeSort = _BidSort.priceAsc),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _SortPill(
                          label: 'Price High',
                          active: _activeSort == _BidSort.priceDesc,
                          onTap: () => setState(() => _activeSort = _BidSort.priceDesc),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _SortPill(
                          label: 'Best Match',
                          active: _activeSort == _BidSort.bestMatch,
                          onTap: () => setState(() => _activeSort = _BidSort.bestMatch),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (brandState.isBidsLoading)
                  const _BidSkeletonList()
                else if (!hasSlotsLeft && acceptedBids.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Text(
                      'All campaign slots are filled. No new bids to review.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
                    ),
                  )
                else if (pendingBids.isEmpty)
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
                      for (var index = 0; index < pendingBids.length; index++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: (() {
                            final bid = pendingBids[index];
                            final creator = creatorsById[bid.creatorId];
                            return BidReviewCard(
                              bid: bid,
                              shadow: const [
                                BoxShadow(
                                  color: AppColors.brandPrimaryGlassShadow,
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                              displayName: bid.creatorFullName,
                              avatarUrl: (bid.creatorAvatarUrl ?? '').trim().isNotEmpty
                                  ? bid.creatorAvatarUrl
                                  : creator?.avatarUrl,
                              onAccept: () => _onAcceptBid(bid),
                              onPass: () => setState(() => _passedBidIds.add(bid.id)),
                              onAvatarTap: () => _openCreatorProfile(
                                bid,
                                displayName: bid.creatorFullName,
                                avatarUrl: (bid.creatorAvatarUrl ?? '').trim().isNotEmpty
                                    ? bid.creatorAvatarUrl
                                    : creator?.avatarUrl,
                              ),
                              onReadMore: (bid.pitch ?? '').trim().isEmpty
                                  ? null
                                  : () => _showPitchDialog(bid),
                            );
                          })(),
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
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
      const SnackBar(content: Text('Matched! Full details now unlocked.')),
    );

    await ref.read(brandProvider.notifier).fetchBrandHome(force: true);
    if (!mounted) return;
    await ref.read(brandProvider.notifier).fetchCampaignBids(widget.id);
  }

  Future<void> _showPitchDialog(CampaignBid bid) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pitch from ${bid.creatorFirstName}', style: AppTypography.displaySM),
                const SizedBox(height: AppSpacing.sm),
                Text(bid.pitch ?? '-', style: AppTypography.bodyMD),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: _ActionPillButton(
                    label: 'Close',
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

  Future<void> _onCancelCollab(CampaignBid bid) async {
    final confirmed = await _showNeoConfirmDialog(
      context,
      title: 'Cancel this collaboration?',
      subtitle:
          'This will end the collaboration and refund the creator wallet fee. Your spent brand credit will not be refunded.',
      confirmLabel: 'Cancel',
      cancelLabel: 'No',
    );

    if (!confirmed || !mounted) return;

    final ok = await ref.read(brandProvider.notifier).cancelAcceptedBid(
          campaignId: widget.id,
          bidId: bid.id,
        );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to cancel this collaboration.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Collaboration cancelled. Creator wallet fee refunded. Brand credit remains used.',
        ),
      ),
    );

    await ref.read(brandProvider.notifier).fetchBrandHome(force: true);
    if (!mounted) return;
    await ref.read(brandProvider.notifier).fetchCampaignBids(widget.id);
  }

  Future<void> _openCreatorProfile(
    CampaignBid bid, {
    String? displayName,
    String? avatarUrl,
  }) async {
    final normalizedDisplayName = (displayName ?? '').trim();

    openProfilePreviewSheet(
      context,
      preview: ProfileSheetPreviewData(
        partnerId: bid.creatorId,
        viewerRole: 'brand',
        partnerRole: 'creator',
        name: normalizedDisplayName.isNotEmpty ? normalizedDisplayName : bid.creatorFirstName,
        fullName: normalizedDisplayName.isNotEmpty ? normalizedDisplayName : bid.creatorFullName,
        avatarUrl: avatarUrl,
        instagramUsername: bid.creatorHandle.trim().isNotEmpty ? bid.creatorHandle : null,
        amountInr: bid.amount,
        collabType: _collabLabel(bid.collabType),
        niche: bid.niches.isNotEmpty ? bid.niches.join(', ') : null,
        tier: bid.tier,
        followers: bid.followersCount,
      ),
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
}

class _ScreenTitleBar extends StatelessWidget {
  const _ScreenTitleBar({required this.title, required this.bidCount});

  final String title;
  final int bidCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.displaySM.copyWith(
              color: AppColors.brandDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        BCBadge(label: '$bidCount bids', variant: BCBadgeVariant.pink),
      ],
    );
  }
}

class _BackHeader extends StatelessWidget {
  const _BackHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brandDark.withValues(alpha: 0.14),
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.brandDark,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CampaignOverviewCard extends StatelessWidget {
  const _CampaignOverviewCard({
    required this.campaign,
    required this.effectiveSlotsFilled,
  });

  final Campaign campaign;
  final int effectiveSlotsFilled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.lightBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.14)),
                ),
                child: const Icon(Symbols.campaign_rounded, color: AppColors.brandDark, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  '${_inr(campaign.minBudget)} - ${_inr(campaign.maxBudget)}',
                  style: AppTypography.displaySM.copyWith(
                    color: AppColors.brandDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${_collabLabel(campaign.collabType)} • Deadline ${DateFormat('d MMM yyyy').format(campaign.deadline ?? DateTime.now())}',
            style: AppTypography.bodySM.copyWith(color: AppColors.muted),
          ),
          if (campaign.description.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(campaign.description, style: AppTypography.bodySM),
          ],
          if (campaign.deliverables.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Deliverables: ${campaign.deliverables.join(', ')}',
              style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
            ),
          ],
          if (campaign.requirements.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Requirements: ${campaign.requirements}',
              style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.18), width: 1.2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: campaign.slotsTotal == 0 ? 0 : effectiveSlotsFilled / campaign.slotsTotal,
                child: const DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.brandPrimaryGlassGradient),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$effectiveSlotsFilled of ${campaign.slotsTotal} slots filled',
            style: AppTypography.bodyXS,
          ),
        ],
      ),
    );
  }
}

class _SortPill extends StatelessWidget {
  const _SortPill({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: active ? AppColors.brandDark : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: active ? AppColors.brandPrimary : AppColors.brandDark,
          ),
        ),
      ),
    );
  }
}

class _ActionPillButton extends StatelessWidget {
  const _ActionPillButton({required this.label, required this.onPressed});

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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.brandDark,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            label,
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

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: size * 0.55, spreadRadius: size * 0.04),
          ],
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
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 172,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.lightBorder),
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
  String cancelLabel = 'Cancel',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.lightBorder),
          ),
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
                    child: _ActionPillButton(
                      label: cancelLabel,
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _ActionPillButton(
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

String _inr(int value) => 'INR ${NumberFormat.decimalPattern('en_IN').format(value)}';

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
