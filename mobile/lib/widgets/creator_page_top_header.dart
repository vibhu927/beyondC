import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/creator_provider.dart';
import '../providers/notification_provider.dart';
import '../features/chat/chat_modal.dart';
import '../features/shared/widgets/notifications_modal.dart';

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 16) return 'Good afternoon';
  if (hour < 19) return 'Good evening';
  return 'Good night';
}

class CreatorPageTopHeader extends ConsumerWidget {
  final double collapseProgress;

  const CreatorPageTopHeader({super.key, this.collapseProgress = 0.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(creatorProfileProvider).valueOrNull;
    final unreadNotifications = ref.watch(unreadCountProvider);
    final unreadChats = ref.watch(chatListProvider.select((state) {
      final role = ref.read(authProvider).role ?? 'creator';
      final active = state.valueOrNull?.active ?? const [];
      var sum = 0;
      for (final chat in active) {
        sum += chat.unreadForRole(role);
      }
      return sum;
    }));

    final displayName = (profile?.displayName?.trim().isNotEmpty ?? false)
        ? profile!.displayName!.trim()
        : profile?.firstName ?? 'Creator';
    final tier = profile?.tier ?? 'Rising Creator';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C';

    return Row(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Opacity(
                opacity: 1.0 - collapseProgress,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.creatorDark.withValues(alpha: 0.16)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: AppTypography.labelLG.copyWith(
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
                          Text('${_getGreeting()},', style: AppTypography.bodySM.copyWith(color: AppColors.muted)),
                          const SizedBox(height: 2),
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.displaySM.copyWith(
                              color: AppColors.creatorDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(tier, style: AppTypography.bodyXS.copyWith(color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Opacity(
                opacity: collapseProgress,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/C.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _HeaderIcon(
          icon: Symbols.notifications_rounded,
          count: unreadNotifications,
          onTap: () => openNotificationsModal(context),
          tooltip: 'Notifications',
        ),
        const SizedBox(width: AppSpacing.sm),
        _HeaderIcon(
          icon: Symbols.send_rounded,
          count: unreadChats,
          onTap: () => openChatModal(context),
          tooltip: 'Messages',
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.count,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final int count;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.creatorDark.withValues(alpha: 0.14)),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, size: 22, color: AppColors.creatorDark),
            splashRadius: 22,
            tooltip: tooltip,
          ),
        ),
        if (count > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.creatorPrimary,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
