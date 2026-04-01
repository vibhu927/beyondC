import 'dart:async';

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
import '../../../data/repositories/notification_repository.dart';
import '../../../data/services/instagram_oauth_service.dart';
import '../../../providers/chat_modal_provider.dart';
import '../../../providers/creator_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/chat_modal/chat_modal.dart';
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
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(creatorHomeProvider.notifier).refresh(),
      ref.read(notificationProvider.notifier).refreshNotifications(),
    ]);
  }

  Future<void> _openNotificationsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLG),
                ),
                border: const Border(
                  top: BorderSide(color: AppColors.ink, width: 2),
                ),
              ),
              child: Consumer(
                builder: (context, ref, _) {
                  final notificationsAsync = ref.watch(notificationProvider);
                  return notificationsAsync.when(
                    loading: () => const Center(child: BCAppLoader()),
                    error: (error, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMD,
                        ),
                      ),
                    ),
                    data: (notifications) {
                      final unreadInSheet =
                          notifications.where((item) => !item.isRead).length;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.screenPadding,
                              AppSpacing.md,
                              AppSpacing.sm,
                              AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Notifications',
                                    style: AppTypography.displaySM,
                                  ),
                                ),
                                if (unreadInSheet > 0)
                                  TextButton(
                                    onPressed: () {
                                      unawaited(ref
                                          .read(notificationProvider.notifier)
                                          .markAllRead());
                                    },
                                    child: Text(
                                      'Clear ($unreadInSheet)',
                                      style: AppTypography.labelMD.copyWith(
                                        color: AppColors.pink,
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.close_rounded),
                                  tooltip: 'Close notifications',
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: notifications.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(AppSpacing.xl),
                                      child: Text(
                                        'No notifications yet.',
                                        style: AppTypography.bodyMD,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    controller: scrollController,
                                    padding: const EdgeInsets.fromLTRB(
                                      AppSpacing.screenPadding,
                                      AppSpacing.lg,
                                      AppSpacing.screenPadding,
                                      AppSpacing.huge,
                                    ),
                                    itemCount: notifications.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: AppSpacing.sm),
                                    itemBuilder: (context, index) {
                                      final notification = notifications[index];
                                      return BCCard(
                                        child: InkWell(
                                          onTap: () {
                                            unawaited(ref
                                                .read(notificationProvider
                                                    .notifier)
                                                .markRead(notification.id));

                                            final route = _routeForNotification(
                                                notification);
                                            if (route == null) return;

                                            Navigator.of(context).pop();
                                            context.push(route);
                                          },
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      notification.title,
                                                      style:
                                                          AppTypography.labelMD,
                                                    ),
                                                    const SizedBox(
                                                      height: AppSpacing.xs,
                                                    ),
                                                    Text(
                                                      notification.body.isEmpty
                                                          ? 'New activity'
                                                          : notification.body,
                                                      style:
                                                          AppTypography.bodySM,
                                                    ),
                                                    const SizedBox(
                                                      height: AppSpacing.xs,
                                                    ),
                                                    Text(
                                                      timeago.format(
                                                          notification
                                                              .createdAt),
                                                      style:
                                                          AppTypography.bodyXS,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (!notification.isRead)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    left: AppSpacing.sm,
                                                    top: AppSpacing.sm,
                                                  ),
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.neon,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      AppSpacing.radiusFull,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
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
          const SnackBar(content: Text('Instagram connection failed. Please try again.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      final message = ref.read(instagramOAuthServiceProvider).extractApiError(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? 'Instagram connection failed.' : message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isConnectingInstagram = false);
      }
    }
  }

  String? _routeForNotification(AppNotification notification) {
    final referenceId = notification.referenceId;

    switch (notification.referenceType) {
      case 'collab':
        if (referenceId == null || referenceId.isEmpty) return null;
        return RouteNames.creatorChat.replaceFirst(':id', referenceId);
      case 'bid':
        return RouteNames.myBids;
      case 'event_invite':
        return RouteNames.creatorEvents;
      case 'campaign':
        if (referenceId == null || referenceId.isEmpty) {
          return RouteNames.creatorCampaigns;
        }
        return RouteNames.campaignDetail.replaceFirst(':id', referenceId);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(creatorHomeProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final unreadChats = ref.watch(chatModalUnreadCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 0,
      ),
      body: RefreshIndicator(
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
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.sm,
                    AppSpacing.screenPadding,
                    AppSpacing.huge,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Hey, ${profile.firstName} 👋',
                              style: AppTypography.displayMD,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () =>
                                    ref.read(themeProvider.notifier).toggle(),
                                tooltip: isDark ? 'Light mode' : 'Dark mode',
                                icon: Icon(
                                  isDark
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  color: isDark
                                      ? AppColors.neon
                                      : AppColors.lightText,
                                ),
                              ),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IconButton(
                                    onPressed: () => openChatModal(context),
                                    icon: Icon(
                                      Icons.mark_chat_unread_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  if (unreadChats > 0)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        width: 9,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusFull,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IconButton(
                                    onPressed: _openNotificationsSheet,
                                    icon: Icon(
                                      Icons.notifications_none_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusFull,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          unreadCount > 99
                                              ? '99+'
                                              : '$unreadCount',
                                          style: AppTypography.labelXS
                                              .copyWith(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (!profile.instagramVerified) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _InstagramConnectBanner(
                          isLoading: _isConnectingInstagram,
                          onConnect: _connectInstagram,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ] else
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
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _StatOrb(
                              emoji: '📩',
                              label: 'Requests',
                              value: '${home.requests.length}',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _StatOrb(
                              emoji: '🤝',
                              label: 'Collabs',
                              value: '${home.activeCollabs.length}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      _SectionHeader(
                        title: 'New Campaigns 🔥',
                        actionLabel: 'See all →',
                        onTap: () => context.push(RouteNames.creatorCampaigns),
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
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
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
                                                timeago
                                                    .format(request.receivedAt),
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
                                          label: Formatters.currency(
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
                                          onTap: () => context
                                              .push(RouteNames.creatorRequests),
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
                                                  content:
                                                      Text('Request accepted.'),
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
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
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
                                        final isCurrent =
                                            collab.currentStep == step;
                                        final isDone =
                                            collab.currentStep > step;
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right:
                                                index == 3 ? 0 : AppSpacing.sm,
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE1306C), Color(0xFFF77737), Color(0xFF833AB4)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connect Instagram',
                  style: AppTypography.labelLG.copyWith(color: AppColors.white),
                ),
                Text(
                  'Verify your account to appear in brand search',
                  style: AppTypography.bodyXS.copyWith(color: AppColors.lightMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
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
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(color: AppColors.ink, width: 2),
            boxShadow: AppShadows.neon,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTypography.labelLG
                      .copyWith(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodyXS,
          textAlign: TextAlign.center,
        ),
      ],
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
