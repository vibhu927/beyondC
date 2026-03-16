import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/campaign_provider.dart';
import '../../../providers/creator_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_app_bar.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../widgets/campaign_card.dart';

class CreatorHomeScreen extends ConsumerStatefulWidget {
  const CreatorHomeScreen({super.key});

  @override
  ConsumerState<CreatorHomeScreen> createState() => _CreatorHomeScreenState();
}

class _CreatorHomeScreenState extends ConsumerState<CreatorHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadInitialData);
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      ref.read(creatorProvider.notifier).fetchCreatorHome(),
      ref.read(campaignProvider.notifier).fetchCampaigns(),
      ref.read(notificationProvider.notifier).fetchNotifications(),
    ]);
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(creatorProvider.notifier).refreshCreatorHome(),
      ref.read(campaignProvider.notifier).refreshCampaigns(),
      ref.read(notificationProvider.notifier).refreshNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final creatorState = ref.watch(creatorProvider);
    final campaignState = ref.watch(campaignProvider);
    final profile = creatorState.creatorProfile;

    return Scaffold(
      appBar: const BCAppBar(title: 'Creator Home'),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.neon,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.xl,
                AppSpacing.screenPadding,
                AppSpacing.huge,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Hey, ${profile?.firstName ?? 'Creator'} 👋',
                    style: AppTypography.displayMD,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      _MiniStatPill(
                        emoji: '💰',
                        label: _rupees(creatorState.walletBalance),
                        backgroundColor: AppColors.neon,
                        textColor: AppColors.ink,
                      ),
                      _MiniStatPill(
                        emoji: '⚡',
                        label: '${creatorState.activeBidsCount} active bids',
                        backgroundColor: AppColors.ink,
                        textColor: AppColors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  SizedBox(
                    height: 98,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _QuickStatCard(
                            label: 'Profile Views',
                            value: '142',
                            sublabel: 'this week'),
                        SizedBox(width: AppSpacing.md),
                        _QuickStatCard(
                            label: 'Requests', value: '3', sublabel: 'pending'),
                        SizedBox(width: AppSpacing.md),
                        _QuickStatCard(
                            label: 'Collabs',
                            value: '7',
                            sublabel: 'completed'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _SectionHeader(
                    title: 'New Campaigns 🔥',
                    actionLabel: 'See all →',
                    onTap: () => context.push(RouteNames.creatorCampaigns),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 220,
                    child: campaignState.isLoading
                        ? ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, __) =>
                                const CampaignCardSkeleton(),
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: AppSpacing.md),
                            itemCount: 5,
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final campaign = campaignState.campaigns[index];
                              return CampaignCard(
                                campaign: campaign,
                                onTap: () => context.push(
                                  RouteNames.campaignDetail
                                      .replaceFirst(':id', campaign.id),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: AppSpacing.md),
                            itemCount: campaignState.campaigns.length,
                          ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _SectionHeader(
                    title: 'Brand Requests 📩',
                    actionLabel: 'See all →',
                    onTap: () => context.push(RouteNames.creatorRequests),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (creatorState.requests.isEmpty)
                    const _EmptyState(
                      emoji: '📭',
                      message: 'No requests yet.\nBrands will reach out soon!',
                    )
                  else
                    Column(
                      children: creatorState.requests.take(3).map((request) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: BCCard(
                            shadow: AppShadows.blue,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.blue,
                                        borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusFull),
                                        border: Border.all(
                                            color: AppColors.ink, width: 2),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        request.brandInitial,
                                        style: AppTypography.labelMD
                                            .copyWith(color: AppColors.white),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'A brand wants to collab',
                                            style: AppTypography.labelLG,
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            timeago.format(request.receivedAt),
                                            style: AppTypography.bodyXS,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    BCBadge(
                                      label: _rupees(request.budget),
                                      variant: BCBadgeVariant.neon,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    BCBadge(
                                      label:
                                          _collabTypeLabel(request.collabType),
                                      variant: _collabTypeVariant(
                                          request.collabType),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    _CompactActionButton(
                                      label: 'View',
                                      isFilled: false,
                                      onTap: () => context
                                          .push(RouteNames.creatorRequests),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    _CompactActionButton(
                                      label: 'Accept',
                                      isFilled: true,
                                      onTap: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('Request accepted.')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _SectionHeader(
                    title: 'Your Active Collabs',
                    actionLabel: 'See all →',
                    onTap: () => context.push(RouteNames.creatorCollabs),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (creatorState.activeCollabs.isEmpty)
                    const _EmptyState(
                      emoji: '🤝',
                      message:
                          'No active collabs yet. Start bidding on campaigns!',
                    )
                  else
                    Column(
                      children:
                          creatorState.activeCollabs.take(2).map((collab) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: BCCard(
                            shadow: AppShadows.neon,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${collab.brandCategory} collab',
                                        style: AppTypography.labelLG,
                                      ),
                                    ),
                                    Text(
                                      _rupees(collab.amount),
                                      style: AppTypography.displaySM,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const Text(
                                  'Brief  ·  Draft  ·  Approved  ·  Posted',
                                  style: AppTypography.bodyXS,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: List.generate(4, (index) {
                                    final step = index + 1;
                                    final isCurrent =
                                        collab.currentStep == step;
                                    final isDone = collab.currentStep > step;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          right:
                                              index == 3 ? 0 : AppSpacing.sm),
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: isCurrent
                                              ? AppColors.neon
                                              : isDone
                                                  ? AppColors.ink
                                                  : AppColors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: AppColors.ink, width: 2),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: BCPrimaryButton.dark(
                                    label: 'Continue →',
                                    onPressed: () =>
                                        context.push(RouteNames.creatorCollabs),
                                    isFullWidth: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatPill extends StatelessWidget {
  const _MiniStatPill({
    required this.emoji,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String emoji;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.labelSM.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.sublabel,
  });

  final String label;
  final String value;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: BCCard(
        shadow: AppShadows.neon,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: AppTypography.bodyXS, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTypography.labelLG
                  .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(sublabel,
                style: AppTypography.bodyXS, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTypography.displaySM)),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.pink,
            textStyle: AppTypography.labelSM,
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.emoji,
    required this.message,
  });

  final String emoji;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodySM.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.label,
    required this.onTap,
    required this.isFilled,
  });

  final String label;
  final VoidCallback onTap;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isFilled ? AppColors.neon : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: Text(label, style: AppTypography.labelSM),
      ),
    );
  }
}

String _rupees(int value) =>
    '₹${NumberFormat.decimalPattern('en_IN').format(value)}';

String _collabTypeLabel(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return 'Paid';
    case CampaignCollabType.barter:
      return 'Barter';
    case CampaignCollabType.hybrid:
      return 'Hybrid';
  }
}

BCBadgeVariant _collabTypeVariant(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return BCBadgeVariant.pink;
    case CampaignCollabType.barter:
      return BCBadgeVariant.blue;
    case CampaignCollabType.hybrid:
      return BCBadgeVariant.purple;
  }
}
