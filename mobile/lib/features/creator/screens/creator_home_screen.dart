import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
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
import '../../../data/services/instagram_oauth_service.dart';
import '../../../providers/creator_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/bc_portal_top_bar.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../shared/widgets/home_carousel_strip.dart';
import '../widgets/campaign_card.dart';

class CreatorHomeScreen extends ConsumerStatefulWidget {
  const CreatorHomeScreen({super.key});

  @override
  ConsumerState<CreatorHomeScreen> createState() => _CreatorHomeScreenState();
}

class _CreatorHomeScreenState extends ConsumerState<CreatorHomeScreen> {
  bool _isConnectingInstagram = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      unawaited(ref.read(notificationProvider.notifier).fetchNotifications());
      unawaited(ref.read(creatorHomeProvider.notifier).refreshSilently());
      ref.read(creatorCampaignsProvider);
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(creatorHomeProvider.notifier).refresh(),
      ref.read(notificationProvider.notifier).refreshNotifications(),
    ]);
  }

  Future<void> _connectInstagram() async {
    if (_isConnectingInstagram) return;

    setState(() => _isConnectingInstagram = true);

    try {
      final oauthService = ref.read(instagramOAuthServiceProvider);
      final result = await oauthService.connectInstagram();

      if (!mounted) return;

      if (result.isSuccess) {
        await ref.read(creatorHomeProvider.notifier).refreshSilently();
        if (!mounted) return;
        ref.invalidate(creatorProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.username == null
                  ? 'Instagram connected. Stats are being fetched...'
                  : '@${result.username} connected. Stats are being fetched...',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Instagram connection failed. Please try again.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      final message =
          ref.read(instagramOAuthServiceProvider).extractApiError(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                message.isEmpty ? 'Instagram connection failed.' : message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isConnectingInstagram = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(creatorHomeProvider);
    return Scaffold(
      extendBody: true,
      appBar: const BCPortalTopBar(),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 0,
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.creator,
        currentIndex: 0,
        child: RefreshIndicator(
          color: AppColors.neon,
          onRefresh: _refresh,
          child: homeAsync.when(
            loading: () => const BCLoadingOverlay(
              isLoading: true,
              child: SizedBox.expand(),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: AppSpacing.xl),
                        if (home.carouselItems.isNotEmpty) ...[
                          HomeCarouselStrip(
                            items: home.carouselItems,
                            height: 128,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if (!profile.instagramVerified) ...[
                          _InstagramConnectBanner(
                            isLoading: _isConnectingInstagram,
                            onConnect: _connectInstagram,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
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
                        Row(
                          children: [
                            Expanded(
                              child: _StatOrb(
                                emoji: '👀',
                                label: 'Followers',
                                value: Formatters.followerCount(
                                  home.profile.followersCount,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _StatOrb(
                                emoji: '📩',
                                label: 'Requests',
                                value: '${home.requests.length}',
                                onTap: () =>
                                    context.push(RouteNames.creatorRequests),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _StatOrb(
                                emoji: '🤝',
                                label: 'Collabs',
                                value: '${home.activeCollabs.length}',
                                onTap: () =>
                                    context.push(RouteNames.creatorCollabs),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        _SectionHeader(
                          title: 'New Campaigns 🔥',
                          actionLabel: 'See all →',
                          onTap: () =>
                              context.push(RouteNames.creatorCampaigns),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          height: 232,
                          child: home.campaigns.isEmpty
                              ? const BCEmptyState(
                                  emoji: '📣',
                                  message: 'No active campaigns right now.',
                                )
                              : ListView.separated(
                                  clipBehavior: Clip.none,
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    2,
                                    AppSpacing.sm,
                                    8,
                                  ),
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
                            message:
                                'No requests yet. Brands will reach out soon!',
                          )
                        else
                          Column(
                            children: home.requests.take(3).map((request) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md),
                                child: BCCard(
                                  shadow: AppShadows.blue,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: AppColors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                                  .copyWith(
                                                      color: AppColors.white),
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
                                                const SizedBox(
                                                    height: AppSpacing.xs),
                                                Text(
                                                  timeago.format(
                                                      request.receivedAt),
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
                                            label: Formatters.currencyFromINR(
                                                request.budget),
                                            variant: BCBadgeVariant.neon,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          BCBadge(
                                            label: _collabTypeLabel(
                                                request.collabType),
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
                                            onTap: () => context.push(
                                                RouteNames.creatorRequests),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _CompactActionButton(
                                            label: 'Accept',
                                            isFilled: true,
                                            onTap: () async {
                                              try {
                                                await ref
                                                    .read(creatorActionsProvider
                                                        .notifier)
                                                    .respondToRequest(
                                                      requestId: request.id,
                                                      action: 'accept',
                                                    );
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Request accepted.'),
                                                  ),
                                                );
                                              } catch (_) {
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Could not accept request.'),
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
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md),
                                child: BCCard(
                                  shadow: AppShadows.neon,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          final isCurrent =
                                              collab.currentStep == step;
                                          final isDone =
                                              collab.currentStep > step;
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              right: index == 3
                                                  ? 0
                                                  : AppSpacing.sm,
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
                                          onPressed: () => context
                                              .push(RouteNames.creatorCollabs),
                                          isFullWidth: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(
                            height: AppSpacing.huge +
                                AppSpacing.xxxl +
                                AppSpacing.lg +
                                AppSpacing.xxl),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InstagramConnectBanner extends StatelessWidget {
  const _InstagramConnectBanner({
    required this.onConnect,
    required this.isLoading,
  });

  final VoidCallback onConnect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      shadow: AppShadows.pink,
      backgroundColor: AppColors.ink,
      borderColor: AppColors.ink,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE1306C),
                  Color(0xFFF77737),
                  Color(0xFF833AB4)
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Symbols.camera_alt_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connect Instagram',
                  style: AppTypography.labelMD.copyWith(color: AppColors.white),
                ),
                Text(
                  'Verify your account to appear in brand search',
                  style: AppTypography.bodyXS
                      .copyWith(color: AppColors.lightMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          BCPrimaryButton.neon(
            label: isLoading ? 'Connecting...' : 'Connect',
            isFullWidth: false,
            isLoading: isLoading,
            onPressed: isLoading ? null : onConnect,
          ),
        ],
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

class _StatOrb extends StatelessWidget {
  const _StatOrb({
    required this.emoji,
    required this.label,
    required this.value,
    this.onTap,
  });

  final String emoji;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(color: AppColors.ink, width: 2),
              boxShadow: AppShadows.neon,
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    value,
                    style: AppTypography.labelLG.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              label,
              style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
