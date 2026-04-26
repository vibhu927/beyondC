import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_back_button.dart';
import '../../chat/chat_screen.dart';
import '../../creator/shared/widgets/creator_design_system.dart';

Future<void> openNotificationsModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _NotificationsSheetBody(scrollController: scrollController);
        },
      );
    },
  );
}

class _NotificationsSheetBody extends ConsumerWidget {
  const _NotificationsSheetBody({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationProvider);
    final role =
        ref.watch(authProvider.select((state) => state.role)) ?? 'creator';
    final unreadCount = ref.watch(unreadCountProvider);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE7EDF7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.ink.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.md,
              AppSpacing.screenPadding,
              AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Notifications',
                          style: AppTypography.displaySM),
                      const SizedBox(height: AppSpacing.xs),
                      InlineTonePill(
                        label: '$unreadCount unread',
                        accent: AppColors.pink,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BCBackButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icons.close_rounded,
                      iconColor: AppColors.ink,
                      backgroundColor: Colors.white.withValues(alpha: 0.92),
                      borderColor: AppColors.ink.withValues(alpha: 0.16),
                      tooltip: 'Close',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: 142,
                      child: GlassButton(
                        label: 'Mark all read',
                        accent: AppColors.neon,
                        onTap: unreadCount > 0
                            ? () => ref
                                .read(notificationProvider.notifier)
                                .markAllRead()
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(child: BCAppLoader()),
              error: (error, _) => BCErrorState(
                message: error.toString(),
                onRetry: () => ref
                    .read(notificationProvider.notifier)
                    .refreshNotifications(),
              ),
              data: (notifications) {
                if (notifications.isEmpty) {
                  return const BCEmptyState(
                    emoji: '🔔',
                    message:
                        'No notifications yet.\nWe\'ll let you know when something happens.',
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 220) {
                      ref
                          .read(notificationProvider.notifier)
                          .loadMoreNotifications();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      0,
                      AppSpacing.screenPadding,
                      AppSpacing.lg,
                    ),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final isUnread = !notification.isRead;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () async {
                            await ref
                                .read(notificationProvider.notifier)
                                .markRead(notification.id);

                            if (!context.mounted) return;
                            Navigator.of(context).pop();

                            if (notification.referenceType == 'collab' &&
                                notification.referenceId != null &&
                                notification.referenceId!.isNotEmpty) {
                              openChatDrawer(context, notification.referenceId!);
                              return;
                            }

                            final route =
                                _routeForNotification(notification, role);
                            if (route != null) {
                              context.push(route);
                            }
                          },
                          child: GlassPanel(
                            accentColor: _typeColor(notification.type),
                            radius: 22,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: _typeColor(notification.type),
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusFull),
                                    border: Border.all(
                                      color: AppColors.ink,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Icon(
                                    _typeIcon(notification.type),
                                    size: 16,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notification.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: (isUnread
                                                      ? AppTypography.labelMD
                                                      : AppTypography.labelSM)
                                                  .copyWith(
                                                color: AppColors.ink,
                                                fontWeight: isUnread
                                                    ? FontWeight.w900
                                                    : FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            timeago.format(
                                              notification.createdAt,
                                            ),
                                            style: AppTypography.bodyXS
                                                .copyWith(
                                                    color: AppColors.muted),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        notification.body.isEmpty
                                            ? notification.title
                                            : notification.body,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.bodySM
                                            .copyWith(color: AppColors.muted),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isUnread)
                                  Container(
                                    margin: const EdgeInsets.only(
                                      left: AppSpacing.md,
                                      top: 6,
                                    ),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.neon,
                                      borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusFull),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
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
      if (role == 'agency') {
        return RouteNames.agencyBids;
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
      return Icons.notifications_rounded;
  }
}
