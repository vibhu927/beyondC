import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_portal_top_bar.dart';
import '../../../widgets/cards/bc_card.dart';

class BrandCampaignsScreen extends ConsumerStatefulWidget {
  const BrandCampaignsScreen({super.key});

  @override
  ConsumerState<BrandCampaignsScreen> createState() =>
      _BrandCampaignsScreenState();
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
      appBar: const BCPortalTopBar(),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.brand,
        currentIndex: 1,
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.brand,
        currentIndex: 1,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.sm,
            AppSpacing.screenPadding,
            AppSpacing.huge,
          ),
          children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _pill('All', _statusFilter == null, () {
                  setState(() => _statusFilter = null);
                }),
                const SizedBox(width: AppSpacing.sm),
                _pill('Active', _statusFilter == CampaignStatus.active, () {
                  setState(() => _statusFilter = CampaignStatus.active);
                }),
                const SizedBox(width: AppSpacing.sm),
                _pill('Paused', _statusFilter == CampaignStatus.paused, () {
                  setState(() => _statusFilter = CampaignStatus.paused);
                }),
                const SizedBox(width: AppSpacing.sm),
                _pill('Completed', _statusFilter == CampaignStatus.completed,
                    () {
                  setState(() => _statusFilter = CampaignStatus.completed);
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state.isLoading)
            const _CampaignShimmerList()
          else if (campaigns.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
              child: Text(
                'No campaigns found for this brand account.\nSample campaigns are tied to the seeded sample brand login.',
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
                      child: BCCard(
                        shadow: AppShadows.pink,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    campaign.title,
                                    style: AppTypography.labelLG,
                                  ),
                                ),
                                BCBadge(
                                  label: _statusLabel(campaign.status),
                                  variant: _statusVariant(campaign.status),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Budget ${_inr(campaign.minBudget)}-${_inr(campaign.maxBudget)}  •  ${_collabType(campaign.collabType)}',
                              style: AppTypography.bodySM
                                  .copyWith(color: AppColors.muted),
                            ),
                            if (campaign.description.trim().isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                campaign.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySM,
                              ),
                            ],
                            if (campaign.requirements.trim().isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Requirements: ${campaign.requirements}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyXS
                                    .copyWith(color: AppColors.muted),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Deadline ${DateFormat('d MMM yyyy').format(campaign.deadline ?? DateTime.now())}',
                              style: AppTypography.bodyXS,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${campaign.bidCount} bids  •  ${campaign.slotsFilled}/${campaign.slotsTotal} slots filled',
                              style: AppTypography.bodyXS,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                onPressed: () => context.push(
                                  RouteNames.campaignBids
                                      .replaceFirst(':id', campaign.id),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.ink, width: 2),
                                  foregroundColor: AppColors.ink,
                                ),
                                child: const Text('View Bids →'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, bool active, VoidCallback onTap) {
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
            color: active ? AppColors.neon : AppColors.ink,
          ),
        ),
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
            baseColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : AppColors.lightDivider,
            highlightColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurfaceAlt
                : AppColors.lightSurfaceAlt,
            child: BCCard(
              child: Column(
                children: [
                  Container(height: 16, color: AppColors.white),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 12, color: AppColors.white),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 12, color: AppColors.white),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 34, color: AppColors.white),
                ],
              ),
            ),
          ),
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

BCBadgeVariant _statusVariant(CampaignStatus status) {
  switch (status) {
    case CampaignStatus.active:
      return BCBadgeVariant.neon;
    case CampaignStatus.paused:
      return BCBadgeVariant.warning;
    case CampaignStatus.completed:
      return BCBadgeVariant.blue;
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
  return '₹${format.format(value)}';
}
