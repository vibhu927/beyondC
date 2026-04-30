import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import 'buttons/bc_back_button.dart';
import '../features/chat/chat_modal.dart';
import '../features/shared/widgets/notifications_modal.dart';

class BCPortalTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const BCPortalTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: AppColors.lightBg,
      surfaceTintColor: Colors.transparent,
      shape: const Border(bottom: BorderSide(color: Colors.transparent, width: 0)),
      flexibleSpace: const ColoredBox(color: AppColors.lightBg),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors.lightBg,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: AppSpacing.screenPadding,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Beyond',
              style: AppTypography.displaySM.copyWith(
                color: AppColors.darkGreen,
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
                border: Border.all(
                  color: AppColors.darkGreen.withValues(alpha: 0.16),
                  width: 1.2,
                ),
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
            BCBackButton(
              onPressed: () => openNotificationsModal(context),
              icon: Icons.notifications_rounded,
              iconColor: AppColors.darkGreen,
              backgroundColor: AppColors.white,
              borderColor: AppColors.darkGreen.withValues(alpha: 0.14),
              buttonSize: 36,
              iconSize: 20,
              tooltip: 'Notifications',
            ),
            if (unreadCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(color: AppColors.ink, width: 1),
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
        Stack(
          clipBehavior: Clip.none,
          children: [
            BCBackButton(
              onPressed: () => openChatModal(context),
              icon: Symbols.send_rounded,
              iconColor: AppColors.darkGreen,
              backgroundColor: AppColors.white,
              borderColor: AppColors.darkGreen.withValues(alpha: 0.14),
              buttonSize: 36,
              iconSize: 20,
              tooltip: 'Messages',
            ),
            if (unreadChats > 0)
              Positioned(
                top: 1,
                right: 1,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(color: AppColors.ink, width: 1),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
