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
import '../../../data/services/instagram_oauth_service.dart';
import '../../../providers/creator_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';

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
            content: Text('Instagram connection failed. Please try again.'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      final message =
          ref.read(instagramOAuthServiceProvider).extractApiError(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(message.isEmpty ? 'Instagram connection failed.' : message),
        ),
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

              return Stack(
                children: [
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.lightBg,
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
                    child: _AmbientGlow(
                      size: 136,
                      color: AppColors.creatorPrimary.withValues(alpha: 0.12),
                    ),
                  ),
                  Positioned(
                    top: 220,
                    left: -42,
                    child: _AmbientGlow(
                      size: 112,
                      color: AppColors.creatorDark.withValues(alpha: 0.1),
                    ),
                  ),
                  ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      MediaQuery.of(context).padding.top + 14,
                      AppSpacing.screenPadding,
                      AppSpacing.huge + navClearance,
                    ),
                    children: [
                      _CreatorTopHeader(
                        name: profile.firstName,
                        notificationsCount: 0,
                        onNotificationsTap: () => context.push(RouteNames.notifications),
                        onProfileTap: () => context.push(RouteNames.creatorProfile),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _CreatorQuickActions(
                        onCampaignsTap: () => context.push(RouteNames.creatorCampaigns),
                        onBidsTap: () => context.push(RouteNames.myBids),
                        onRequestsTap: () => context.push(RouteNames.creatorRequests),
                        onCollabsTap: () => context.push(RouteNames.creatorCollabs),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (!profile.instagramVerified)
                        _InstagramConnectBanner(
                          isLoading: _isConnectingInstagram,
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
                                          context.push(RouteNames.creatorCollabs),
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
                        height: 252,
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
                      if (home.requests.isEmpty)
                        const BCEmptyState(
                          emoji: ' ',
                          message:
                              'No requests yet. Brands will reach out soon.',
                        )
                      else
                        Column(
                          children: home.requests.take(3).map((request) {
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CreatorTopHeader extends StatelessWidget {
  const _CreatorTopHeader({
    required this.name,
    required this.notificationsCount,
    required this.onNotificationsTap,
    required this.onProfileTap,
  });

  final String name;
  final int notificationsCount;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final firstName = name.trim().isEmpty ? 'Creator' : name.trim();
    final avatarLabel = firstName.substring(0, 1).toUpperCase();

    return Row(
      children: [
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.creatorDark.withValues(alpha: 0.16)),
            ),
            alignment: Alignment.center,
            child: Text(
              avatarLabel,
              style: AppTypography.labelLG.copyWith(
                color: AppColors.creatorDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good to see you,',
                style: AppTypography.bodySM.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 2),
              Text(
                firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.displaySM.copyWith(
                  color: AppColors.creatorDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: onNotificationsTap,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.creatorDark.withValues(alpha: 0.14)),
                ),
                alignment: Alignment.center,
                child: const Icon(Symbols.notifications_rounded, color: AppColors.creatorDark),
              ),
            ),
            if (notificationsCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: AppColors.brandPrimaryGlassGradient,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ],
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
    this.radius = 28,
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
            border: _uniformBorder(accentColor),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: _neoShadows(accentColor),
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
    required this.isLoading,
  });

  final VoidCallback onConnect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      accentColor: AppColors.pink,
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
            label: isLoading ? 'Connecting' : 'Connect',
            accent: AppColors.pink,
            onTap: isLoading ? null : onConnect,
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
    return _GlassPanel(
      accentColor: AppColors.neon,
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
                      border: _uniformBorder(
                        AppColors.neon,
                        width: 0.95,
                        // emphasisWidth: 1.6,
                      ),
                      boxShadow: _neoShadows(
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
                        accent: AppColors.blue,
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
                      accent: AppColors.blue,
                      onTap: onRequestsTap,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _MetricTile(
                      label: 'Collabs',
                      value: '$collabs',
                      accent: AppColors.pink,
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
        border: _uniformBorder(accent),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _neoShadows(
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.displaySM.copyWith(
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
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.pink,
            textStyle: AppTypography.labelSM.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          child: Text(actionLabel),
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
    final locationCopy = campaign.targetCity ??
        campaign.targetState ??
        'Pan India';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 296,
        child: _GlassPanel(
          accentColor: _collabTypeAccent(campaign.collabType),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _avatarColor(campaign.brandInitial),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      campaign.brandInitial,
                      style: AppTypography.labelMD.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Brand in ${campaign.brandCategory}',
                      style: AppTypography.labelMD.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _InlineTonePill(
                    label: _deadlineLabel(campaign.deadline),
                    accent: AppColors.ink,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${Formatters.currencyFromINR(campaign.minBudget)} - '
                      '${Formatters.currencyFromINR(campaign.maxBudget)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.displaySM.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _InlineTonePill(
                    label: _collabTypeLabel(campaign.collabType),
                    accent: _collabTypeAccent(campaign.collabType),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                deliverables.isEmpty ? 'Deliverables shared on brief' : deliverables,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySM.copyWith(
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _InlineTonePill(
                    label: locationCopy,
                    accent: AppColors.blue,
                  ),
                  if (hasBid)
                    _InlineTonePill(
                      label: 'Bid sent',
                      accent: AppColors.pink,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
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
                    accent: hasBid ? AppColors.blue : AppColors.neon,
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
    return _GlassPanel(
      accentColor: AppColors.pink,
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
              _GlassButton(
                label: 'View',
                accent: AppColors.ink,
                onTap: onView,
              ),
              const SizedBox(width: AppSpacing.sm),
              _GlassButton(
                label: 'Accept',
                accent: AppColors.neon,
                onTap: onAccept,
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
      child: _GlassPanel(
        accentColor: _collabStatusAccent(collab.status),
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
              Formatters.currency(collab.amount),
              style: AppTypography.displaySM.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Brief / Draft / Approved / Posted',
              style: AppTypography.bodyXS.copyWith(
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _ProgressRail(currentStep: collab.currentStep),
            const SizedBox(height: AppSpacing.md),
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
                _GlassButton(
                  label: 'Continue',
                  accent: AppColors.pink,
                  onTap: onTap,
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
              border: _uniformBorder(
                accent,
                width: 0.95,
                // emphasisWidth: 1.45,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              boxShadow: _neoShadows(
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
          border: _uniformBorder(
            accent,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: _neoShadows(
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

List<BoxShadow> _sheetShadows() {
  return [
    BoxShadow(
      color: AppColors.blue.withValues(alpha: 0.14),
      offset: const Offset(6, 6),
      blurRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
  ];
}

Border _uniformBorder(
  Color accent, {
  double width = 1.5,
}) {
  return Border.all(
    color: accent.withValues(alpha: 0.4),
    width: width,
  );
}

List<BoxShadow> _neoShadows(
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
      return AppColors.pink;
    case CampaignCollabType.barter:
      return AppColors.blue;
    case CampaignCollabType.hybrid:
      return AppColors.purple;
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
      return AppColors.blue;
    case 'active':
      return AppColors.neon;
    default:
      return AppColors.pink;
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
  const palette = [
    AppColors.pink,
    AppColors.blue,
    AppColors.purple,
    AppColors.orange,
  ];

  if (initial.isEmpty) return palette.first;
  return palette[initial.codeUnitAt(0) % palette.length];
}
