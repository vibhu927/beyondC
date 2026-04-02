import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import '../features/chat/chat_modal.dart';
import '../features/shared/widgets/notifications_modal.dart';

class BCPortalTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const BCPortalTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);
    final unreadChats = ref.watch(chatListProvider.select((state) {
      final role = ref.read(authProvider).role ?? 'creator';
      final active = state.valueOrNull?.active ?? const [];
      var sum = 0;
      for (final chat in active) {
        sum += chat.unreadForRole(role);
      }
      return sum;
    }));

    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AppBar(
      elevation: 0,
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leadingWidth: 56,
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () => openNotificationsModal(context),
            icon: Icon(
              Icons.notifications_none_rounded,
              color: onSurface,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: surface, width: 1),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: AppTypography.labelXS.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
      centerTitle: true,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Beyond',
              style: AppTypography.displaySM.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.35,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.neon,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: Text(
                'C',
                style: AppTypography.labelMD.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => openChatModal(context),
              icon: Icon(Icons.chat_bubble_rounded, color: onSurface),
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
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(color: surface, width: 1),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
