import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/creator_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_app_bar.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
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
      ref.read(creatorHomeProvider.notifier).refresh(),
      ref.read(notificationProvider.notifier).fetchNotifications(),
    ]);
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(creatorHomeProvider.notifier).refresh(),
      ref.read(notificationProvider.notifier).refreshNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(creatorHomeProvider);

    return Scaffold(
      appBar: const BCAppBar(title: 'Creator Home'),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.neon,
        onRefresh: _refresh,
        child: homeAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.ink),
          ),
          error: (error, _) => BCErrorState(
            message: error.toString(),
            onRetry: _refresh,
          ),
          data: (home) {
            final profile = home.profile;

            return CustomScrollView(
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
                        'Hey, ${profile.firstName} 👋',
                        style: AppTypography.displayMD,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          _MiniStatPill(
                            emoji: '💰',
                            label: Formatters.currency(home.wallet.balance),
                            backgroundColor: AppColors.neon,
                            textColor: AppColors.ink,
                          ),
                          _MiniStatPill(
                            emoji: '⚡',
                            label: '${home.activeBidsCount} active bids',
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
                          children: [
                            const _QuickStatCard(
                              label: 'Profile Views',
                              value: '142',
                              sublabel: 'this week',
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _QuickStatCard(
                              label: 'Requests',
                              value: '${home.requests.length}',
                              sublabel: 'pending',
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _QuickStatCard(
                              label: 'Collabs',
                              value: '${home.activeCollabs.length}',
                              sublabel: 'active',
                            ),
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
                        child: home.campaigns.isEmpty
                            ? const BCEmptyState(
                                emoji: '📣',
                                message: 'No active campaigns right now.',
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final campaign = home.campaigns[index];
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
                                itemCount: home.campaigns.length,
                              ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      _SectionHeader(
                        title: 'Brand Requests 📩',
                        actionLabel: 'See all →',
                        onTap: () => context.push(RouteNames.creatorRequests),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (home.requests.isEmpty)
                        const BCEmptyState(
                          emoji: '📭',
                          message: 'No requests yet. Brands will reach out soon!',
                        )
                      else
                        Column(
                          children: home.requests.take(3).map((request) {
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
                                              AppSpacing.radiusFull,
                                            ),
                                            border: Border.all(
                                              color: AppColors.ink,
                                              width: 2,
                                            ),
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
                                          label: Formatters.currency(request.budget),
                                          variant: BCBadgeVariant.neon,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        BCBadge(
                                          label: _collabTypeLabel(request.collabType),
                                          variant: _collabTypeVariant(request.collabType),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Row(
                                      children: [
                                        _CompactActionButton(
                                          label: 'View',
                                          isFilled: false,
                                          onTap: () =>
                                              context.push(RouteNames.creatorRequests),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        _CompactActionButton(
                                          label: 'Accept',
                                          isFilled: true,
                                          onTap: () async {
                                            try {
                                              await ref
                                                  .read(creatorActionsProvider.notifier)
                                                  .respondToRequest(
                                                    requestId: request.id,
                                                    action: 'accept',
                                                  );
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Request accepted.'),
                                                ),
                                              );
                                            } catch (_) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Could not accept request.'),
                                                ),
                                              );
                                            }
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
                      if (home.activeCollabs.isEmpty)
                        const BCEmptyState(
                          emoji: '🤝',
                          message:
                              'No active collabs yet. Start bidding on campaigns!',
                        )
                      else
                        Column(
                          children: home.activeCollabs.take(2).map((collab) {
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
                                          Formatters.currency(collab.amount),
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
                                        final isCurrent = collab.currentStep == step;
                                        final isDone = collab.currentStep > step;
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right: index == 3 ? 0 : AppSpacing.sm,
                                          ),
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
                                                color: AppColors.ink,
                                                width: 2,
                                              ),
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
            );
          },
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
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
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
            Text(label, style: AppTypography.bodyXS, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTypography.labelLG
                  .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              sublabel,
              style: AppTypography.bodyXS,
              textAlign: TextAlign.center,
            ),
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
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
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
