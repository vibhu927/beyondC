import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/brand_page_top_header.dart';

class BrandCampaignsScreen extends ConsumerStatefulWidget {
  const BrandCampaignsScreen({super.key});

  @override
  ConsumerState<BrandCampaignsScreen> createState() => _BrandCampaignsScreenState();
}

class _BrandCampaignsScreenState extends ConsumerState<BrandCampaignsScreen> {
  CampaignStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(brandProvider.notifier).fetchBrandHome();
      ref.read(brandRequestsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(brandProvider);

    final campaigns = state.campaigns.where((campaign) {
      if (_statusFilter == null) return true;
      return campaign.status == _statusFilter;
    }).toList();

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.brand,
        currentIndex: 1,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: FloatingActionButton(
          heroTag: 'brandCampaignsFiltersFab',
          onPressed: _openFilters,
          backgroundColor: AppColors.brandDark,
          foregroundColor: AppColors.brandPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            side: BorderSide(
              color: AppColors.brandDark.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: const Icon(Icons.tune_rounded),
        ),
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.brand,
        currentIndex: 1,
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.lightBg),
              ),
            ),
            Positioned(
              top: -46,
              right: -32,
              child: _GlowOrb(
                size: 136,
                color: AppColors.brandPrimary.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              top: 220,
              left: -44,
              child: _GlowOrb(
                size: 112,
                color: AppColors.brandDark.withValues(alpha: 0.08),
              ),
            ),
            ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                MediaQuery.of(context).padding.top + 14,
                AppSpacing.screenPadding,
                AppSpacing.huge,
              ),
              children: [
                const BrandPageTopHeader(),
                const SizedBox(height: AppSpacing.md),
                if (state.isLoading)
                  const _CampaignShimmerList()
                else if (campaigns.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
                    child: Text(
                      _statusFilter == null
                          ? 'No campaigns found for this brand account.\nCreate your first campaign to start receiving bids.'
                          : 'No campaigns found for this selected status.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
                    ),
                  )
                else
                  Column(
                    children: campaigns
                        .map(
                          (campaign) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _CampaignCard(
                              campaign: campaign,
                              onViewBids: () => context.push(
                                RouteNames.campaignBids.replaceFirst(':id', campaign.id),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFilters() async {
    CampaignStatus? workingFilter = _statusFilter;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.lightBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.16)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.huge,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filters',
                      style: AppTypography.displaySM.copyWith(
                        color: AppColors.brandDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text('Campaign Status', style: AppTypography.labelMD),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _FilterPill(
                          label: 'All',
                          active: workingFilter == null,
                          onTap: () => setSheetState(() => workingFilter = null),
                        ),
                        _FilterPill(
                          label: 'Active',
                          active: workingFilter == CampaignStatus.active,
                          onTap: () => setSheetState(() => workingFilter = CampaignStatus.active),
                        ),
                        _FilterPill(
                          label: 'Paused',
                          active: workingFilter == CampaignStatus.paused,
                          onTap: () => setSheetState(() => workingFilter = CampaignStatus.paused),
                        ),
                        _FilterPill(
                          label: 'Completed',
                          active: workingFilter == CampaignStatus.completed,
                          onTap: () => setSheetState(() => workingFilter = CampaignStatus.completed),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _BriefStyleActionButton(
                      label: 'Apply',
                      onPressed: () {
                        setState(() => _statusFilter = workingFilter);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign, required this.onViewBids});

  final Campaign campaign;
  final VoidCallback onViewBids;

  @override
  Widget build(BuildContext context) {
    final deliverables = campaign.deliverables.take(2).join(' / ');
    final location = campaign.targetCity ?? campaign.targetState ?? 'Pan India';
    final budgetLabel = '${_inr(campaign.minBudget)} - ${_inr(campaign.maxBudget)}';
    final deadline = DateFormat('d MMM yyyy').format(campaign.deadline ?? DateTime.now());
    final createdAt = timeago.format(campaign.createdAt ?? DateTime.now());

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
                alignment: Alignment.center,
                child: Text(
                  campaign.brandInitial,
                  style: AppTypography.labelMD.copyWith(
                    color: AppColors.brandDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLG.copyWith(
                        color: AppColors.brandDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$location • $createdAt',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            budgetLabel,
            style: AppTypography.displaySM.copyWith(
              color: AppColors.brandDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            deliverables.isEmpty ? _collabType(campaign.collabType) : deliverables,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _CampaignStatusPill(
                label: _statusLabel(campaign.status),
                isActive: campaign.status == CampaignStatus.active,
              ),
              const Spacer(),
              Text(
                '${campaign.bidCount} bids • ${campaign.slotsFilled}/${campaign.slotsTotal} slots',
                style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Deadline $deadline',
            style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: _BriefStyleActionButton(label: 'View Bids', onPressed: onViewBids),
          ),
        ],
      ),
    );
  }
}

class _CampaignShimmerList extends StatelessWidget {
  const _CampaignShimmerList();

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
              height: 214,
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

class _CampaignStatusPill extends StatelessWidget {
  const _CampaignStatusPill({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? null : AppColors.brandDark.withValues(alpha: 0.08),
        gradient: isActive ? AppColors.brandPrimaryGlassGradient : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: isActive
              ? AppColors.brandPrimaryGlassBorder
              : AppColors.brandDark.withValues(alpha: 0.16),
        ),
        boxShadow: isActive
            ? [
                const BoxShadow(
                  color: AppColors.brandPrimaryGlassShadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: AppTypography.labelXS.copyWith(
          color: AppColors.brandDark,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.active, required this.onTap});
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

class _BriefStyleActionButton extends StatelessWidget {
  const _BriefStyleActionButton({required this.label, required this.onPressed});

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

String _statusLabel(CampaignStatus status) {
  switch (status) {
    case CampaignStatus.active:
      return 'Active';
    case CampaignStatus.paused:
      return 'Paused';
    case CampaignStatus.completed:
      return 'Completed';
  }
}

String _collabType(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return 'Paid';
    case CampaignCollabType.barter:
      return 'Barter';
    case CampaignCollabType.hybrid:
      return 'Hybrid';
  }
}

String _inr(int value) {
  final format = NumberFormat.decimalPattern('en_IN');
  return 'INR ${format.format(value)}';
}


