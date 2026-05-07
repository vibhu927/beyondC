import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/brand_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import '../features/chat/chat_modal.dart';
import '../features/shared/widgets/notifications_modal.dart';

class BrandPageTopHeader extends ConsumerWidget {
  const BrandPageTopHeader({
    super.key,
    this.showBrandIdentity = true,
    this.showBackButton = false,
    this.onBack,
  });

  final bool showBrandIdentity;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(brandProfileProvider).valueOrNull;
    final unreadNotifications = ref.watch(unreadCountProvider);
    final unreadChats = ref.watch(chatListProvider.select((state) {
      final role = ref.read(authProvider).role ?? 'brand';
      final active = state.valueOrNull?.active ?? const [];
      var sum = 0;
      for (final chat in active) {
        sum += chat.unreadForRole(role);
      }
      return sum;
    }));

    final avatarLabel = profile?.logoInitial ?? 'B';
    final brandName = profile?.brandName ?? 'Brand';
    final category = profile?.brandCategory ?? 'General';

    return Row(
      children: [
        if (showBrandIdentity) ...[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.16)),
            ),
            alignment: Alignment.center,
            child: Text(
              avatarLabel,
              style: AppTypography.labelLG.copyWith(
                color: AppColors.brandDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning,', style: AppTypography.bodySM.copyWith(color: AppColors.muted)),
                const SizedBox(height: 2),
                Text(
                  brandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.displaySM.copyWith(
                    color: AppColors.brandDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(category, style: AppTypography.bodyXS.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
        ] else if (showBackButton) ...[
          _HeaderIcon(
            icon: Symbols.arrow_back_rounded,
            count: 0,
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            tooltip: 'Back',
          ),
          const Spacer(),
        ] else ...[
          const Spacer(),
        ],
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
            border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.14)),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, size: 22, color: AppColors.brandDark),
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
                color: AppColors.brandPrimary,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

