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
  static const double _carouselHeight = 200;
  static const double _contentTopInset = 168;
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
              final navClearance = MediaQuery.of(context).padding.bottom + 84;
              final profile = home.profile;

              return Stack(
                children: [
                  if (home.carouselItems.isNotEmpty)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        child: Container(
                          height: _carouselHeight,
                          color: const Color(0xFF0D0D0D),
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: HomeCarouselStrip(
                            items: home.carouselItems,
                            height: 176,
                          ),
                        ),
                      ),
                    ),
                  CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: home.carouselItems.isNotEmpty
                              ? _contentTopInset
                              : AppSpacing.lg,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const SizedBox(height: AppSpacing.lg),
                            if (!profile.instagramVerified) ...[
                              _InstagramConnectBanner(
                                isLoading: _isConnectingInstagram,
                                onConnect: _connectInstagram,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                            _CreatorPulseBoard(
                              walletBalance:
                                  Formatters.currency(home.wallet.balance),
                              activeBids: home.activeBidsCount,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _SignalStatsRow(
                              followers: Formatters.followerCount(
                                home.profile.followersCount,
                              ),
                              requests: '${home.requests.length}',
                              collabs: '${home.activeCollabs.length}',
                              onRequestsTap: () =>
                                  context.push(RouteNames.creatorRequests),
                              onCollabsTap: () =>
                                  context.push(RouteNames.creatorCollabs),
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
                                                .replaceFirst(
                                                    ':id', campaign.id),
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
                              onTap: () =>
                                  context.push(RouteNames.creatorRequests),
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
                                                          color:
                                                              AppColors.white),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: AppSpacing.md),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'A brand wants to collab',
                                                      style:
                                                          AppTypography.labelLG,
                                                    ),
                                                    const SizedBox(
                                                        height: AppSpacing.xs),
                                                    Text(
                                                      timeago.format(
                                                          request.receivedAt),
                                                      style:
                                                          AppTypography.bodyXS,
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
                                                label:
                                                    Formatters.currencyFromINR(
                                                        request.budget),
                                                variant: BCBadgeVariant.neon,
                                              ),
                                              const SizedBox(
                                                  width: AppSpacing.sm),
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
                                              const SizedBox(
                                                  width: AppSpacing.sm),
                                              _CompactActionButton(
                                                label: 'Accept',
                                                isFilled: true,
                                                onTap: () async {
                                                  try {
                                                    await ref
                                                        .read(
                                                            creatorActionsProvider
                                                                .notifier)
                                                        .respondToRequest(
                                                          requestId: request.id,
                                                          action: 'accept',
                                                        );
                                                    if (!context.mounted)
                                                      return;
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Request accepted.'),
                                                      ),
                                                    );
                                                  } catch (_) {
                                                    if (!context.mounted)
                                                      return;
                                                    ScaffoldMessenger.of(
                                                            context)
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
                              onTap: () =>
                                  context.push(RouteNames.creatorCollabs),
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
                                children:
                                    home.activeCollabs.take(2).map((collab) {
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
                                                Formatters.currency(
                                                    collab.amount),
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
                                              onPressed: () => context.push(
                                                  RouteNames.creatorCollabs),
                                              isFullWidth: false,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            SizedBox(
                              height: AppSpacing.huge +
                                  AppSpacing.xxxl +
                                  AppSpacing.lg +
                                  AppSpacing.xxl +
                                  navClearance,
                            ),
                          ]),
                        ),
                      ),
                    ],
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

class _CreatorPulseBoard extends StatelessWidget {
  const _CreatorPulseBoard({
    required this.walletBalance,
    required this.activeBids,
  });

  final String walletBalance;
  final int activeBids;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.ink, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            offset: Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.neon,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.white, width: 1.25),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Symbols.account_balance_wallet_rounded,
                  size: 16,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Top Up Balance',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMD.copyWith(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.darkBorder, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$activeBids bids',
                      style: AppTypography.labelXS.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            walletBalance,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.displayLG.copyWith(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalStatsRow extends StatelessWidget {
  const _SignalStatsRow({
    required this.followers,
    required this.requests,
    required this.collabs,
    required this.onRequestsTap,
    required this.onCollabsTap,
  });

  final String followers;
  final String requests;
  final String collabs;
  final VoidCallback onRequestsTap;
  final VoidCallback onCollabsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SignalStatTile(
            label: 'Followers',
            value: followers,
            accent: AppColors.neon,
            icon: Symbols.group_rounded,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SignalStatTile(
            label: 'Requests',
            value: requests,
            accent: AppColors.blue,
            icon: Symbols.inbox_rounded,
            onTap: onRequestsTap,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SignalStatTile(
            label: 'Collabs',
            value: collabs,
            accent: AppColors.pink,
            icon: Symbols.handshake_rounded,
            onTap: onCollabsTap,
          ),
        ),
      ],
    );
  }
}

class _SignalStatTile extends StatelessWidget {
  const _SignalStatTile({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final Color accent;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        border: Border.all(color: AppColors.ink, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            offset: Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppColors.ink, width: 1.2),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 13, color: AppColors.ink),
              ),
              const Spacer(),
              Container(
                width: 18,
                height: 3,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.displaySM.copyWith(
              color: AppColors.ink,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodyXS.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        onTap: onTap,
        child: content,
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
