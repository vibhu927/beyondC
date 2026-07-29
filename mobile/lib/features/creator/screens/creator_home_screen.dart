import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../shared/widgets/creator_design_system.dart';
import '../../../providers/creator_provider.dart';
import '../widgets/instagram_connect_sheet.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/creator_page_top_header.dart';

class CreatorHomeScreen extends ConsumerStatefulWidget {
  const CreatorHomeScreen({super.key});

  @override
  ConsumerState<CreatorHomeScreen> createState() => _CreatorHomeScreenState();
}

class _CreatorHomeScreenState extends ConsumerState<CreatorHomeScreen> {
  final _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (mounted) setState(() => _scrollOffset = _scrollController.offset);
    });
    Future<void>.microtask(() {
      unawaited(ref.read(notificationProvider.notifier).fetchNotifications());
      unawaited(ref.read(creatorHomeProvider.notifier).refreshSilently());
      ref.read(creatorCampaignsProvider);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(creatorHomeProvider.notifier).refresh(),
      ref.read(notificationProvider.notifier).refreshNotifications(),
    ]);
  }

  Future<void> _connectInstagram() async {
    final connected = await openInstagramConnectSheet(context, ref);
    if (!mounted) return;

    if (connected) {
      await ref.read(creatorHomeProvider.notifier).refreshSilently();
      if (!mounted) return;
      ref.invalidate(creatorProfileProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Instagram connected. Stats are being fetched...'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(creatorHomeProvider);

    return Theme(
      data: Theme.of(context).copyWith(
        snackBarTheme: Theme.of(context).snackBarTheme.copyWith(
          behavior: SnackBarBehavior.fixed,
        ),
      ),
      child: Scaffold(
        extendBody: true,
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
              final navClearance = MediaQuery.of(context).padding.bottom + 104;
              final topInset = MediaQuery.of(context).padding.top + 14;
              const headerHeight = 48.0;
              const headerGap = 34.0;
              final sheetTop = topInset + headerHeight + headerGap;
              final headerSlide = _scrollOffset.clamp(0.0, sheetTop);
              final collapseProgress = (headerSlide / (headerHeight + headerGap)).clamp(0.0, 1.0);
              final collapsedTop = MediaQuery.of(context).padding.top + 8;
              final headerTop = lerpDouble(topInset, collapsedTop, collapseProgress)!;

              return Stack(
                children: [
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.lightBg,
                            Color(0xFFDCE8C7),
                            Color(0xFFC9D8B0),
                          ],
                          stops: [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Carousel intentionally disabled for now per product direction.
                  // if (home.carouselItems.isNotEmpty) {
                  //   HomeCarouselStrip(...)
                  // }
                  Positioned(
                    top: -46,
                    right: -54,
                    child: AmbientGlow(
                      size: 136,
                      color: AppColors.creatorPrimary.withValues(alpha: 0.12),
                    ),
                  ),
                  Positioned(
                    top: 220,
                    left: -42,
                    child: AmbientGlow(
                      size: 112,
                      color: AppColors.creatorDark.withValues(alpha: 0.1),
                    ),
                  ),
                  Positioned.fill(
                    child: ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(0, sheetTop, 0, 0),
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.lightBg,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: AppColors.creatorDark,
                                width: 2.2,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.screenPadding,
                              AppSpacing.lg,
                              AppSpacing.screenPadding,
                              AppSpacing.huge + navClearance,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            _CreatorQuickActions(
                              onCampaignsTap: () => context.push(RouteNames.creatorCampaigns),
                              onBidsTap: () => context.push(RouteNames.myBids),
                              onRequestsTap: () => context.push(RouteNames.creatorRequests),
                              onCollabsTap: () => context.push(RouteNames.creatorCollabs),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (home.activeCollabs.isNotEmpty)
                              _CollabStatusBanner(
                                collab: home.activeCollabs.first,
                                onTap: () => context.push(
                                  RouteNames.collabDetail
                                      .replaceFirst(':id', home.activeCollabs.first.id),
                                ),
                              ),
                            if (home.activeCollabs.isNotEmpty)
                              const SizedBox(height: AppSpacing.lg),
                            if (!profile.instagramVerified)
                              _InstagramConnectBanner(
                                onConnect: _connectInstagram,
                              ),
                            const SizedBox(height: AppSpacing.xxxl),
                            _SectionHeading(
                              title: 'Your Active Collabs',
                              subtitle: 'Keep momentum moving this week',
                              actionLabel: 'See all',
                              onTap: () => context.push(RouteNames.creatorCollabs),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (home.activeCollabs.isEmpty)
                              const BCEmptyState(
                                emoji: ' ',
                                message:
                                    'No active collabs yet. Start bidding on campaigns.',
                              )
                            else
                              Column(
                                children: home.activeCollabs
                                    .take(2)
                                    .map((collab) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: AppSpacing.md,
                                          ),
                                          child: _CollabTrackerCard(
                                            collab: collab,
                                            onTap: () =>
                                                context.push(
                                                  RouteNames.collabDetail
                                                      .replaceFirst(':id', collab.id),
                                                ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            const SizedBox(height: AppSpacing.xxxl),
                            _SectionHeading(
                              title: 'New Campaigns',
                              subtitle: 'Fresh briefs that match your vibe',
                              actionLabel: 'See all',
                              onTap: () => context.push(RouteNames.creatorCampaigns),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              height: 266,
                              child: home.campaigns.isEmpty
                                  ? const BCEmptyState(
                                      emoji: ' ',
                                      message: 'No active campaigns right now.',
                                    )
                                  : ListView.separated(
                                      clipBehavior: Clip.none,
                                      padding: const EdgeInsets.only(
                                        right: AppSpacing.sm,
                                        bottom: 8,
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: home.campaigns.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: AppSpacing.md),
                                      itemBuilder: (context, index) {
                                        final campaign = home.campaigns[index];
                                        return _MinimalCampaignCard(
                                          campaign: campaign,
                                          hasBid: home.hasBidForCampaign(campaign.id),
                                          onTap: () => context.push(
                                            RouteNames.campaignDetail
                                                .replaceFirst(':id', campaign.id),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: AppSpacing.xxxl),
                            _SectionHeading(
                              title: 'Brand Requests',
                              subtitle:
                                  'Direct asks from brands that already want you',
                              actionLabel: 'See all',
                              onTap: () => context.push(RouteNames.creatorRequests),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (home.requests.where((r) => r.status == 'pending').isEmpty)
                              const BCEmptyState(
                                emoji: ' ',
                                message:
                                    'No requests yet. Brands will reach out soon.',
                              )
                            else
                              Column(
                                children: home.requests.where((r) => r.status == 'pending').take(3).map((request) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: _RequestCard(
                                      request: request,
                                      onView: () =>
                                          context.push(RouteNames.creatorRequests),
                                      onAccept: () async {
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
                                              content: Text(
                                                'Could not accept request.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: collapsedTop + 48 + 16,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightBg.withValues(alpha: collapseProgress * 0.95),
                          border: collapseProgress > 0.5
                              ? const Border(
                                  bottom: BorderSide(color: AppColors.lightBorder),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: headerTop,
                    left: AppSpacing.screenPadding,
                    right: AppSpacing.screenPadding,
                    child: CreatorPageTopHeader(collapseProgress: collapseProgress),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      ),
    );
  }
}

class _CreatorQuickActions extends StatelessWidget {
  const _CreatorQuickActions({
    required this.onCampaignsTap,
    required this.onBidsTap,
    required this.onRequestsTap,
    required this.onCollabsTap,
  });

  final VoidCallback onCampaignsTap;
  final VoidCallback onBidsTap;
  final VoidCallback onRequestsTap;
  final VoidCallback onCollabsTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: Row(
        children: [
          Expanded(
            child: _QuickActionTile(
              icon: Symbols.campaign_rounded,
              label: 'Campaigns',
              onTap: onCampaignsTap,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _QuickActionTile(
              icon: Symbols.gavel_rounded,
              label: 'My Bids',
              onTap: onBidsTap,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _QuickActionTile(
              icon: Symbols.mail_rounded,
              label: 'Requests',
              onTap: onRequestsTap,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _QuickActionTile(
              icon: Symbols.handshake_rounded,
              label: 'Collabs',
              onTap: onCollabsTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.creatorDark.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.creatorDark, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelXS.copyWith(
                color: AppColors.creatorDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.size,
    required this.color,
  });

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
            BoxShadow(
              color: color,
              blurRadius: size * 0.7,
              spreadRadius: size * 0.08,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = AppSpacing.radiusLG,
    this.backgroundColor,
    this.accentColor = AppColors.blue,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? backgroundColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withValues(alpha: 0.9),
            border: uniformBorder(accentColor),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: neoShadows(accentColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InstagramConnectBanner extends StatelessWidget {
  const _InstagramConnectBanner({
    required this.onConnect,
  });

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      accentColor: AppColors.pink,
      radius: 22,
      backgroundColor: AppColors.white.withValues(alpha: 0.88),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE1306C),
                  Color(0xFFF77737),
                  Color(0xFF833AB4),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Symbols.photo_camera_front_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connect Instagram',
                  style: AppTypography.labelMD.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Turn on discovery and make your profile easier to trust.',
                  style: AppTypography.bodyXS.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _GlassButton(
            label: 'Connect',
            accent: AppColors.pink,
            onTap: onConnect,
          ),
        ],
      ),
    );
  }
}

class _CreatorSnapshotCard extends StatelessWidget {
  const _CreatorSnapshotCard({
    required this.walletBalance,
    required this.followers,
    required this.activeBids,
    required this.requests,
    required this.collabs,
    required this.onWalletTap,
    required this.onRequestsTap,
    required this.onCollabsTap,
  });

  final String walletBalance;
  final String followers;
  final int activeBids;
  final int requests;
  final int collabs;
  final VoidCallback onWalletTap;
  final VoidCallback onRequestsTap;
  final VoidCallback onCollabsTap;

  @override
  Widget build(BuildContext context) {
    return _CreatorCardShell(
      accent: AppColors.neon,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Creator snapshot',
                  style: AppTypography.labelLG.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _GlassButton(
                label: 'Top up',
                accent: AppColors.neon,
                onTap: onWalletTap,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.ink,
                          AppColors.ink.withValues(alpha: 0.92),
                          const Color(0xFF1B2440),
                        ],
                      ),
                      border: uniformBorder(
                        AppColors.neon,
                        width: 0.95,
                        // emphasisWidth: 1.6,
                      ),
                      boxShadow: neoShadows(
                        AppColors.neon,
                        alpha: 0.16,
                        offset: 3,
                        blurRadius: 14,
                      ),
                    ),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.neon,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Symbols.account_balance_wallet_rounded,
                              size: 16,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Wallet balance',
                            style: AppTypography.labelSM.copyWith(
                              color: AppColors.white.withValues(alpha: 0.74),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          walletBalance,
                          maxLines: 1,
                          style: AppTypography.displayLG.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _InlineTonePill(
                        label: '$activeBids active bids in motion',
                        accent: AppColors.neon,
                        onDark: true,
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _MetricTile(
                      label: 'Followers',
                      value: followers,
                      accent: AppColors.neon,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _MetricTile(
                      label: 'Requests',
                      value: '$requests',
                      accent: AppColors.neon,
                      onTap: onRequestsTap,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _MetricTile(
                      label: 'Collabs',
                      value: '$collabs',
                      accent: AppColors.neon,
                      onTap: onCollabsTap,
                    ),
                  ],
                ),
              ),
          ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.accent,
    this.onTap,
  });

  final String label;
  final String value;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: uniformBorder(accent),
        borderRadius: BorderRadius.circular(20),
        boxShadow: neoShadows(
          accent,
          alpha: 0.12,
          offset: 3,
          blurRadius: 12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyXS.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.labelLG.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return GestureDetector(
      onTap: onTap,
      child: content,
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.displaySM.copyWith(
                  color: AppColors.creatorDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodyXS.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.creatorDark.withValues(alpha: 0.14)),
          ),
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.creatorDark,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 6,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              actionLabel,
              style: AppTypography.labelSM.copyWith(
                color: AppColors.creatorDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MinimalCampaignCard extends StatelessWidget {
  const _MinimalCampaignCard({
    required this.campaign,
    required this.hasBid,
    required this.onTap,
  });

  final Campaign campaign;
  final bool hasBid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final deliverables = campaign.deliverables.take(2).join(' / ');
    final locationCopy = campaign.targetCity ?? campaign.targetState ?? 'Pan India';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 296,
        child: _CreatorCardShell(
          accent: _collabTypeAccent(campaign.collabType),
          padding: const EdgeInsets.all(AppSpacing.lg),
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
                      border: Border.all(
                        color: AppColors.creatorDark.withValues(alpha: 0.14),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      campaign.brandInitial,
                      style: AppTypography.labelMD.copyWith(
                        color: AppColors.creatorDark,
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
                            color: AppColors.creatorDark,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          locationCopy,
                          style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${Formatters.currencyFromINR(campaign.minBudget)} - ${Formatters.currencyFromINR(campaign.maxBudget)}',
                style: AppTypography.displaySM.copyWith(
                  color: AppColors.creatorDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                deliverables.isEmpty ? 'Deliverables shared on brief' : deliverables,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySM.copyWith(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _InlineTonePill(
                    label: hasBid ? 'Bid sent' : _collabTypeLabel(campaign.collabType),
                    accent: AppColors.neon,
                  ),
                  const Spacer(),
                  _CardActionButton(
                    label: locationCopy,
                    onPressed: onTap,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${campaign.bidCount} bids so far',
                      style: AppTypography.bodyXS.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  _GlassButton(
                    label: hasBid ? 'View' : 'Bid now',
                    accent: hasBid ? AppColors.ink : AppColors.blue,
                    onTap: onTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onView,
    required this.onAccept,
  });

  final CollabRequest request;
  final VoidCallback onView;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return _CreatorCardShell(
      accent: AppColors.neon,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _avatarColor(request.brandInitial),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  request.brandInitial,
                  style: AppTypography.labelMD.copyWith(
                    color: AppColors.white,
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
                      request.brandName,
                      style: AppTypography.labelLG.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${request.brandCategory} / ${timeago.format(request.receivedAt)}',
                      style: AppTypography.bodyXS.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _InlineTonePill(
                label: Formatters.currencyFromINR(request.budget),
                accent: AppColors.neon,
              ),
              _InlineTonePill(
                label: _collabTypeLabel(request.collabType),
                accent: _collabTypeAccent(request.collabType),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const _InlineTonePill(
                label: 'Request',
                accent: AppColors.neon,
              ),
              const Spacer(),
              _CardActionButton(
                label: 'View',
                onPressed: onView,
              ),
              const SizedBox(width: AppSpacing.sm),
              _CardActionButton(
                label: 'Accept',
                onPressed: onAccept,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CollabTrackerCard extends StatelessWidget {
  const _CollabTrackerCard({
    required this.collab,
    required this.onTap,
  });

  final Collab collab;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _CreatorCardShell(
        accent: _collabStatusAccent(collab.status),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${collab.brandCategory} collab',
                    style: AppTypography.labelLG.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _InlineTonePill(
                  label: _collabStatusLabel(collab.status),
                  accent: _collabStatusAccent(collab.status),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              Formatters.currencyFromINR(collab.amount),
              style: AppTypography.displaySM.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Brief / Draft / Approved / Posted',
              style: AppTypography.bodyXS.copyWith(
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProgressRail(currentStep: collab.currentStep),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Keep the momentum and finish the next milestone.',
                    style: AppTypography.bodyXS.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ),
                _CardActionButton(
                  label: 'Continue',
                  onPressed: onTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRail extends StatelessWidget {
  const _ProgressRail({
    required this.currentStep,
  });

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        final step = index + 1;
        final done = currentStep > step;
        final current = currentStep == step;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == 3 ? 0 : AppSpacing.sm,
            ),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: current
                    ? AppColors.neon
                    : done
                        ? AppColors.ink
                        : Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(color: AppColors.ink, width: 1.4),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CreatorCardShell extends StatelessWidget {
  const _CreatorCardShell({
    required this.child,
    required this.accent,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
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
          BoxShadow(
            color: accent.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.label,
    required this.onPressed,
  });

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
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.creatorDark,
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

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: accent.withValues(
                alpha: accent == AppColors.ink ? 0.08 : 0.16,
              ),
              border: uniformBorder(accent, width: 0.95),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              boxShadow: neoShadows(
                accent,
                alpha: 0.18,
                offset: 3,
                blurRadius: 10,
              ),
            ),
            child: Text(
              label,
              style: AppTypography.labelSM.copyWith(
                color: accent == AppColors.neon ? AppColors.ink : accent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollabStatusBanner extends StatelessWidget {
  const _CollabStatusBanner({
    required this.collab,
    required this.onTap,
  });

  final Collab collab;
  final VoidCallback onTap;

  String get _statusLabel {
    switch (collab.collabStatus) {
      case 'working_on_draft':
        return 'Working on draft';
      case 'draft_ready':
        return 'Draft ready';
      case 'content_posted':
        return 'Content posted';
      case 'completed':
        return 'Completed';
      default:
        return 'Just started';
    }
  }

  Color get _statusColor {
    switch (collab.collabStatus) {
      case 'working_on_draft':
        return const Color(0xFF5B7FFF);
      case 'draft_ready':
        return const Color(0xFF8B5CF6);
      case 'content_posted':
        return const Color(0xFFEC4899);
      case 'completed':
        return const Color(0xFF10B981);
      default:
        return AppColors.darkGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _statusColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _statusColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.update_rounded,
                size: 20,
                color: _statusColor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collab.brandCategory,
                    style: AppTypography.labelSM.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _statusLabel,
                    style: AppTypography.bodyXS.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineTonePill extends StatelessWidget {
  const _InlineTonePill({
    required this.label,
    required this.accent,
    this.onDark = false,
  });

  final String label;
  final Color accent;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: onDark ? 0.24 : 0.12),
          border: uniformBorder(accent),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: neoShadows(
            accent,
            alpha: onDark ? 0.14 : 0.1,
            offset: 2.5,
            blurRadius: 8,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelXS.copyWith(
            color: onDark ? AppColors.white : AppColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

Border uniformBorder(
  Color accent, {
  double width = 1.5,
}) {
  return Border.all(
    color: accent.withValues(alpha: 0.4),
    width: width,
  );
}

List<BoxShadow> neoShadows(
  Color accent, {
  double alpha = 0.16,
  double offset = 4,
  double blurRadius = 14,
}) {
  return [
    BoxShadow(
      color: accent.withValues(alpha: alpha),
      offset: Offset(offset, offset),
      blurRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: blurRadius,
      offset: const Offset(0, 10),
    ),
  ];
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

Color _collabTypeAccent(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return AppColors.neon;
    case CampaignCollabType.barter:
      return AppColors.creatorDark;
    case CampaignCollabType.hybrid:
      return AppColors.creatorDark;
  }
}

String _collabStatusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'in_progress':
      return 'In Progress';
    case 'active':
      return 'Active';
    default:
      return 'Live';
  }
}

Color _collabStatusAccent(String status) {
  switch (status.toLowerCase()) {
    case 'in_progress':
      return AppColors.creatorDark;
    case 'active':
      return AppColors.neon;
    default:
      return AppColors.creatorDark;
  }
}

String _deadlineLabel(DateTime deadline) {
  final duration = deadline.difference(DateTime.now());
  if (duration.isNegative) {
    return 'Ended ${timeago.format(deadline)}';
  }
  if (duration.inDays >= 1) return '${duration.inDays}d left';
  if (duration.inHours >= 1) return '${duration.inHours}h left';
  return '${duration.inMinutes.clamp(1, 59)}m left';
}

Color _avatarColor(String initial) {
  return AppColors.creatorDark;
}
