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
import '../../../providers/brand_provider.dart';
import '../../../providers/chat_modal_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/chat_modal/chat_modal.dart';

class BrandHomeScreen extends ConsumerStatefulWidget {
  const BrandHomeScreen({super.key});

  @override
  ConsumerState<BrandHomeScreen> createState() => _BrandHomeScreenState();
}

class _BrandHomeScreenState extends ConsumerState<BrandHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadInitialData);
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
                                    separatorBuilder: (_, __) => const SizedBox(
                                      height: AppSpacing.sm,
                                    ),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await ref.read(brandProvider.notifier).fetchBrandHome(showLoader: true);
    unawaited(ref.read(notificationProvider.notifier).fetchNotifications());
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(brandProvider.notifier).refreshBrandHome(),
      ref.read(notificationProvider.notifier).refreshNotifications(),
    ]);
  }

  String? _routeForNotification(dynamic notification) {
    final referenceType = notification.referenceType?.toString();
    final referenceId = notification.referenceId?.toString();

    switch (referenceType) {
      case 'collab':
        if (referenceId == null || referenceId.isEmpty) return null;
        return RouteNames.brandChat.replaceFirst(':id', referenceId);
      case 'bid':
        if (referenceId == null || referenceId.isEmpty) {
          return RouteNames.brandCampaigns;
        }
        return RouteNames.campaignBids.replaceFirst(':id', referenceId);
      case 'event_invite':
        if (referenceId == null || referenceId.isEmpty) {
          return RouteNames.brandEvents;
        }
        return RouteNames.eventInvites.replaceFirst(':id', referenceId);
      case 'campaign':
        return RouteNames.brandCampaigns;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandState = ref.watch(brandProvider);
    final notificationAsync = ref.watch(notificationProvider);
    final brandProfile = brandState.brandProfile;
    final activityFeed =
        (notificationAsync.valueOrNull ?? const []).take(4).toList();
    final unreadCount = ref.watch(unreadCountProvider);
    final unreadChats = ref.watch(chatModalUnreadCountProvider);

    return Scaffold(
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.brand,
        currentIndex: 0,
      ),
      body: BCLoadingOverlay(
        isLoading: brandState.isLoading,
        child: RefreshIndicator(
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Hey, ${brandProfile?.brandName ?? 'Brand'} 👋',
                            style: AppTypography.displayMD,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  onPressed: () => openChatModal(context),
                                  icon: const Icon(
                                    Icons.mark_chat_unread_rounded,
                                    color: AppColors.ink,
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
                                  icon: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppColors.ink,
                                  ),
                                ),
                                if (unreadCount > 0)
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
                          ],
                        ),
                      ],
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
                            onTap: () =>
                                context.push(RouteNames.createCampaign),
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
                          Icon(Icons.arrow_forward_rounded,
                              color: AppColors.ink),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    _SectionHeader(
                      title: 'Active Collabs',
                      actionLabel: 'Manage →',
                      onTap: () => context.push(RouteNames.brandCollabs),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (brandState.activeCollabs.isEmpty)
                      const _EmptyState(
                        emoji: '🤝',
                        message:
                            'No active collabs yet.\nAccept a bid or request to see live collaborations here.',
                      )
                    else
                      SizedBox(
                        height: 196,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final collab = brandState.activeCollabs[index];
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
                                          child: Text(collab.creatorName,
                                              style: AppTypography.labelLG),
                                        ),
                                        BCBadge(
                                          label:
                                              _collabStatusLabel(collab.status),
                                          variant: _collabStatusVariant(
                                              collab.status),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    BCBadge(
                                      label: collab.campaignTitle,
                                      variant: BCBadgeVariant.neon,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      _collabMeta(collab),
                                      style: AppTypography.bodySM
                                          .copyWith(color: AppColors.muted),
                                    ),
                                    const Spacer(),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: BCPrimaryButton.dark(
                                        label: 'Open Collabs →',
                                        onPressed: () => context
                                            .push(RouteNames.brandCollabs),
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
                          itemCount: brandState.activeCollabs.length,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xxxl),
                    const Text('Recent Activity',
                        style: AppTypography.displaySM),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
    required this.title,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTypography.displaySM)),
        if (actionLabel != null && onTap != null)
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

BCBadgeVariant _collabStatusVariant(String status) {
  switch (status.toLowerCase()) {
    case 'in_progress':
      return BCBadgeVariant.blue;
    case 'active':
      return BCBadgeVariant.neon;
    default:
      return BCBadgeVariant.warning;
  }
}

String _collabMeta(ActiveCollabSummary collab) {
  final amount = collab.agreedAmount;
  final startedAt = collab.startedAt;

  final amountCopy = amount != null ? 'Rs $amount' : 'Amount not set';
  final startedCopy = startedAt != null
      ? 'Started ${timeago.format(startedAt)}'
      : 'Start date pending';

  return '$amountCopy • $startedCopy';
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
