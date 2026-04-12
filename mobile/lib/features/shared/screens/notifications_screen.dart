import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../chat/chat_screen.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 220;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(notificationProvider.notifier).loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationProvider);
    final role =
        ref.watch(authProvider.select((state) => state.role)) ?? 'creator';
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Notifications', style: AppTypography.displaySM),
        actions: [
          if (unreadCount > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neon,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.ink, width: 1.2),
                ),
                child: Text(
                  '$unreadCount unread',
                  style: AppTypography.labelXS.copyWith(color: AppColors.ink),
                ),
              ),
            ),
          TextButton(
            onPressed: () =>
                ref.read(notificationProvider.notifier).markAllRead(),
            child: Text(
              'Mark all read',
              style: AppTypography.labelMD.copyWith(color: AppColors.pink),
            ),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: BCAppLoader()),
        error: (error, _) => BCErrorState(
          message: error.toString(),
          onRetry: () =>
              ref.read(notificationProvider.notifier).refreshNotifications(),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const BCEmptyState(
              emoji: '🔔',
              message:
                  'No notifications yet.\nWe\'ll let you know when something happens.',
            );
          }

          return ListView.separated(
            controller: _scrollController,
            itemCount: notifications.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.divider),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isUnread = !notification.isRead;

              return InkWell(
                onTap: () async {
                  await ref
                      .read(notificationProvider.notifier)
                      .markRead(notification.id);

                  if (!context.mounted) return;
                  if (notification.referenceType == 'collab' &&
                      notification.referenceId != null &&
                      notification.referenceId!.isNotEmpty) {
                    openChatDrawer(context, notification.referenceId!);
                    return;
                  }

                  final route = _routeForNotification(notification, role);
                  if (route != null) {
                    context.push(route);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _typeColor(notification.type),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          border: Border.all(color: AppColors.ink, width: 1.5),
                        ),
                        child: Icon(
                          _typeIcon(notification.type),
                          size: 20,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: (isUnread
                                      ? AppTypography.labelLG
                                      : AppTypography.labelMD)
                                  .copyWith(color: AppColors.ink),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              notification.body.isEmpty
                                  ? notification.title
                                  : notification.body,
                              style: AppTypography.bodySM
                                  .copyWith(color: AppColors.muted),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              timeago.format(notification.createdAt),
                              style: AppTypography.bodyXS,
                            ),
                          ],
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(top: AppSpacing.sm),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.neon,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String? _routeForNotification(AppNotification notification, String role) {
    final referenceId = notification.referenceId;

    switch (notification.referenceType) {
      case 'collab':
        return null;
      case 'bid':
        if (role == 'creator') {
          return RouteNames.myBids;
        }
        if (referenceId == null) return RouteNames.brandCampaigns;
        return RouteNames.campaignBids.replaceFirst(':id', referenceId);
      case 'event_invite':
        if (role == 'creator') {
          return RouteNames.creatorEvents;
        }
        if (referenceId == null) return RouteNames.brandEvents;
        return RouteNames.eventInvites.replaceFirst(':id', referenceId);
      case 'campaign':
        if (referenceId == null) return RouteNames.creatorCampaigns;
        return RouteNames.campaignDetail.replaceFirst(':id', referenceId);
      default:
        return null;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'bid_received':
        return AppColors.pink;
      case 'bid_accepted':
        return AppColors.success;
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

  IconData _typeIcon(String type) {
    switch (type) {
      case 'bid_received':
        return Symbols.assignment_rounded;
      case 'bid_accepted':
        return Symbols.check_circle_rounded;
      case 'event_invite':
        return Symbols.confirmation_number_rounded;
      case 'collab_matched':
        return Symbols.handshake_rounded;
      case 'request_received':
        return Symbols.mail_rounded;
      default:
        return Symbols.notifications_rounded;
    }
  }
}
