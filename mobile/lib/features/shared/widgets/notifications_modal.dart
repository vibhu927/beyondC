import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
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
    final role = ref.watch(authProvider.select((state) => state.role)) ?? 'creator';
    final unreadCount = ref.watch(unreadCountProvider);
    final rolePrimary = _rolePrimary(role);
    final roleDark = _roleDark(role);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: roleDark.withValues(alpha: 0.16), width: 1.2),
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
                      Text(
                        'Notifications',
                        style: AppTypography.displaySM.copyWith(
                          color: roleDark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _StatusPill(
                        label: '$unreadCount unread',
                        isPrimary: unreadCount > 0,
                        primaryColor: rolePrimary,
                        darkColor: roleDark,
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
                      iconColor: roleDark,
                      backgroundColor: Colors.white.withValues(alpha: 0.96),
                      borderColor: roleDark.withValues(alpha: 0.16),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: 142,
                      child: _BriefStyleActionButton(
                        label: 'Mark all read',
                        darkColor: roleDark,
                        onPressed: unreadCount > 0
                            ? () => ref.read(notificationProvider.notifier).markAllRead()
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
                onRetry: () => ref.read(notificationProvider.notifier).refreshNotifications(),
              ),
              data: (notifications) {
                if (notifications.isEmpty) {
                  return const BCEmptyState(
                    emoji: '🔔',
                    message: 'No notifications yet.\nWe will let you know when something happens.',
                  );
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 220) {
                      ref.read(notificationProvider.notifier).loadMoreNotifications();
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
                          borderRadius: BorderRadius.circular(26),
                          onTap: () async {
                            await ref.read(notificationProvider.notifier).markRead(notification.id);
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            if (notification.referenceType == 'collab' &&
                                notification.referenceId != null &&
                                notification.referenceId!.isNotEmpty) {
                              openChatDrawer(context, notification.referenceId!);
                              return;
                            }
                            final route = _routeForNotification(notification, role);
                            if (route != null) context.push(route);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightBg,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                    border: Border.all(color: roleDark.withValues(alpha: 0.14), width: 1.2),
                                  ),
                                  child: Icon(_typeIcon(notification.type), size: 18, color: _typeColor(notification.type, roleDark)),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notification.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: (isUnread ? AppTypography.labelMD : AppTypography.labelSM).copyWith(
                                                color: roleDark,
                                                fontWeight: isUnread ? FontWeight.w900 : FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            timeago.format(notification.createdAt),
                                            style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        notification.body.isEmpty ? notification.title : notification.body,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.bodySM.copyWith(color: AppColors.muted),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isUnread)
                                  Container(
                                    margin: const EdgeInsets.only(left: AppSpacing.md, top: 6),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: rolePrimary,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.isPrimary, required this.primaryColor, required this.darkColor});
  final String label;
  final bool isPrimary;
  final Color primaryColor;
  final Color darkColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? primaryColor : darkColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: darkColor.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: AppTypography.labelXS.copyWith(
          color: darkColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BriefStyleActionButton extends StatelessWidget {
  const _BriefStyleActionButton({required this.label, required this.onPressed, required this.darkColor});
  final String label;
  final VoidCallback? onPressed;
  final Color darkColor;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: disabled ? darkColor.withValues(alpha: 0.4) : darkColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
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

String? _routeForNotification(AppNotification notification, String role) {
  final referenceId = notification.referenceId;
  switch (notification.referenceType) {
    case 'collab':
      return null;
    case 'bid':
      if (role == 'creator') return RouteNames.myBids;
      if (role == 'agency') return RouteNames.agencyBids;
      if (referenceId == null) return RouteNames.brandCampaigns;
      return RouteNames.campaignBids.replaceFirst(':id', referenceId);
    case 'event_invite':
      if (role == 'creator') return RouteNames.creatorEvents;
      if (referenceId == null) return RouteNames.brandEvents;
      return RouteNames.eventInvites.replaceFirst(':id', referenceId);
    case 'campaign':
      if (referenceId == null) return RouteNames.creatorCampaigns;
      return RouteNames.campaignDetail.replaceFirst(':id', referenceId);
    default:
      return null;
  }
}

Color _typeColor(String type, Color fallbackDark) {
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
      return fallbackDark;
  }
}

Color _rolePrimary(String role) {
  switch (role) {
    case 'brand':
      return AppColors.brandPrimary;
    case 'agency':
      return AppColors.agencyPrimary;
    default:
      return AppColors.creatorPrimary;
  }
}

Color _roleDark(String role) {
  switch (role) {
    case 'brand':
      return AppColors.brandDark;
    case 'agency':
      return AppColors.agencyDark;
    default:
      return AppColors.creatorDark;
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
