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
import '../../../providers/brand_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_app_bar.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../widgets/creator_card.dart';

class BrandHomeScreen extends ConsumerStatefulWidget {
  const BrandHomeScreen({super.key});

  @override
  ConsumerState<BrandHomeScreen> createState() => _BrandHomeScreenState();
}

class _BrandHomeScreenState extends ConsumerState<BrandHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _discoveryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadInitialData);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      ref.read(brandProvider.notifier).fetchBrandHome(),
      ref.read(notificationProvider.notifier).fetchNotifications(),
    ]);
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(brandProvider.notifier).refreshBrandHome(),
      ref.read(notificationProvider.notifier).refreshNotifications(),
    ]);
  }

  void _openFiltersSheet() {
    final activeFilter = ref.read(brandProvider).activeFilter;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLG)),
        side: BorderSide(color: AppColors.ink, width: 2),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter creators', style: AppTypography.displaySM),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _filters.map((filter) {
                  final isActive = filter == activeFilter;
                  return GestureDetector(
                    onTap: () {
                      ref.read(brandProvider.notifier).setActiveFilter(filter);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.ink : AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(color: AppColors.ink, width: 2),
                      ),
                      child: Text(
                        filter,
                        style: AppTypography.labelSM.copyWith(
                          color: isActive ? AppColors.neon : AppColors.ink,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreatorDetails(CreatorPreview creator) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLG)),
        side: BorderSide(color: AppColors.ink, width: 2),
      ),
      builder: (context) {
        return Padding(
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
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(color: AppColors.ink, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      creator.initials,
                      style: AppTypography.labelLG
                          .copyWith(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(creator.firstName, style: AppTypography.displaySM),
                        const SizedBox(height: AppSpacing.xs),
                        BCBadge(
                            label: creator.tier,
                            variant: _tierBadgeVariant(creator.tier)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: creator.niches
                    .map((niche) =>
                        BCBadge(label: niche, variant: BCBadgeVariant.outline))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(creator.bio,
                  style: AppTypography.bodyMD.copyWith(color: AppColors.muted)),
              const SizedBox(height: AppSpacing.lg),
              BCCard(
                shadow: AppShadows.blue,
                child: Row(
                  children: [
                    Expanded(
                        child: Text(creator.followerRange,
                            style: AppTypography.labelSM)),
                    Expanded(
                      child: Text(
                        '${creator.engagementRate.toStringAsFixed(1)}% engagement',
                        style: AppTypography.bodySM,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _rupees(creator.startingPrice),
                        style: AppTypography.labelSM,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              BCPrimaryButton.dark(
                label: 'Send Request →',
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Request sent to ${creator.firstName}. 1 credit used.')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final brandState = ref.watch(brandProvider);
    final notificationAsync = ref.watch(notificationProvider);
    final brandProfile = brandState.brandProfile;
    final filteredCreators = brandState.filteredCreators;
    final activityFeed =
        (notificationAsync.valueOrNull ?? const []).take(4).toList();

    return Scaffold(
      appBar: const BCAppBar(title: 'Brand Home'),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.brand,
        currentIndex: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.neon,
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scrollController,
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
                    'Hey, ${brandProfile?.brandName ?? 'Brand'} 👋',
                    style: AppTypography.displayMD,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      _MiniStatPill(
                        emoji: '⚡',
                        label: '${brandState.creditBalance} credits',
                        backgroundColor: AppColors.blue,
                        textColor: AppColors.white,
                      ),
                      _MiniStatPill(
                        emoji: '📢',
                        label: '${brandState.activeCampaignCount} campaigns',
                        backgroundColor: AppColors.ink,
                        textColor: AppColors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          emoji: '📢',
                          title: 'Post Campaign',
                          subtitle: 'Let creators bid for you',
                          shadow: AppShadows.pink,
                          onTap: () => context.push(RouteNames.createCampaign),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _ActionCard(
                          emoji: '🔍',
                          title: 'Find Creators',
                          subtitle: 'Browse and send requests',
                          shadow: AppShadows.neon,
                          onTap: () => context.push(RouteNames.brandDiscover),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BCCard(
                    shadow: AppShadows.purple,
                    onTap: () => context.push(RouteNames.createEvent),
                    child: const Row(
                      children: [
                        Text('🎟️', style: TextStyle(fontSize: 30)),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Host an Event',
                                  style: AppTypography.labelLG),
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                'Invite creators to your IRL event',
                                style: AppTypography.bodyXS,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_rounded, color: AppColors.ink),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _SectionHeader(
                    key: _discoveryKey,
                    title: 'Discover Creators 🔍',
                    trailing: IconButton(
                      onPressed: _openFiltersSheet,
                      icon:
                          const Icon(Icons.tune_rounded, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isActive = filter == brandState.activeFilter;
                        return GestureDetector(
                          onTap: () => ref
                              .read(brandProvider.notifier)
                              .setActiveFilter(filter),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.ink : AppColors.white,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusFull),
                              border:
                                  Border.all(color: AppColors.ink, width: 2),
                            ),
                            child: Text(
                              filter,
                              style: AppTypography.labelSM.copyWith(
                                color:
                                    isActive ? AppColors.neon : AppColors.ink,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (brandState.isLoading)
                    Column(
                      children: List.generate(
                        3,
                        (index) => const Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                          child: CreatorCardSkeleton(),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: filteredCreators.map((creator) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: CreatorCard(
                            creator: creator,
                            onTap: () => _showCreatorDetails(creator),
                            onSendRequest: () => _showCreatorDetails(creator),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _SectionHeader(
                    title: 'My Campaigns',
                    actionLabel: 'Manage →',
                    onTap: () => context.push(RouteNames.brandCampaigns),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (brandState.campaigns.isEmpty)
                    const _EmptyState(
                      emoji: '📢',
                      message: 'No campaigns yet. Post your first one!',
                    )
                  else
                    SizedBox(
                      height: 196,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final campaign = brandState.campaigns[index];
                          return SizedBox(
                            width: 260,
                            child: BCCard(
                              shadow: AppShadows.pink,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(campaign.title,
                                            style: AppTypography.labelLG),
                                      ),
                                      BCBadge(
                                        label: _statusLabel(campaign.status),
                                        variant:
                                            _statusVariant(campaign.status),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  BCBadge(
                                    label: '${campaign.bidCount} bids received',
                                    variant: BCBadgeVariant.neon,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    _deadlineCopy(
                                      campaign.deadline ?? DateTime.now(),
                                    ),
                                    style: AppTypography.bodySM
                                        .copyWith(color: AppColors.muted),
                                  ),
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: BCPrimaryButton.dark(
                                      label: 'View Bids →',
                                      onPressed: () => context.push(
                                        RouteNames.campaignBids
                                            .replaceFirst(':id', campaign.id),
                                      ),
                                      isFullWidth: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.md),
                        itemCount: brandState.campaigns.length,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxxl),
                  const Text('Recent Activity', style: AppTypography.displaySM),
                  const SizedBox(height: AppSpacing.lg),
                  Column(
                    children: activityFeed.map((activity) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: BCCard(
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _activityColor(activity.type),
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusFull),
                                  border: Border.all(
                                      color: AppColors.ink, width: 2),
                                ),
                                child: Icon(
                                  _activityIcon(activity.type),
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_activityDescription(activity),
                                        style: AppTypography.bodySM),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      timeago.format(activity.createdAt),
                                      style: AppTypography.bodyXS,
                                    ),
                                  ],
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
          Text(label, style: AppTypography.labelSM.copyWith(color: textColor)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.shadow,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final List<BoxShadow> shadow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      shadow: shadow,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.labelLG),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: AppTypography.bodyXS),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTypography.displaySM)),
        if (trailing != null)
          trailing!
        else if (actionLabel != null && onTap != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.pink,
              textStyle: AppTypography.labelSM,
            ),
            child: Text(actionLabel!),
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
              textAlign: TextAlign.center,
              style: AppTypography.bodySM.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

const _filters = [
  'All',
  'Fashion',
  'Fitness',
  'Food',
  'Tech',
  'Beauty',
  'Travel'
];

String _rupees(int value) =>
    '₹${NumberFormat.decimalPattern('en_IN').format(value)}';

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

BCBadgeVariant _tierBadgeVariant(String tier) {
  switch (tier.toLowerCase()) {
    case 'mid':
      return BCBadgeVariant.blue;
    case 'macro':
      return BCBadgeVariant.purple;
    case 'nano':
    case 'micro':
      return BCBadgeVariant.neon;
    default:
      return BCBadgeVariant.outline;
  }
}

String _deadlineCopy(DateTime deadline) {
  final duration = deadline.difference(DateTime.now());
  if (duration.isNegative) {
    return 'Ended ${timeago.format(deadline)}';
  }
  if (duration.inDays >= 1) {
    return '${duration.inDays} days left';
  }
  if (duration.inHours >= 1) {
    return '${duration.inHours} hours left';
  }
  return '${duration.inMinutes.clamp(1, 59)} minutes left';
}

Color _activityColor(String type) {
  switch (type) {
    case 'bid_received':
      return AppColors.pink;
    case 'bid_accepted':
      return AppColors.neon;
    case 'event_invite':
      return AppColors.purple;
    case 'collab_matched':
      return AppColors.blue;
    case 'request_received':
      return AppColors.orange;
    default:
      return AppColors.ink;
  }
}

IconData _activityIcon(String type) {
  switch (type) {
    case 'bid_received':
      return Icons.assignment_rounded;
    case 'bid_accepted':
      return Icons.check_circle_rounded;
    case 'event_invite':
      return Icons.confirmation_num_rounded;
    case 'collab_matched':
      return Icons.handshake_rounded;
    case 'request_received':
      return Icons.mail_rounded;
    default:
      return Icons.notifications_rounded;
  }
}

String _activityDescription(dynamic activity) {
  final body = (activity.body as String?) ?? '';
  if (body.trim().isNotEmpty) return body;
  return (activity.title as String?) ?? 'New activity';
}
