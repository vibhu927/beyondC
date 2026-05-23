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

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 16) return 'Good afternoon';
  if (hour < 19) return 'Good evening';
  return 'Good night';
}

class BrandPageTopHeader extends ConsumerWidget {
  final double collapseProgress;

  const BrandPageTopHeader({
    super.key,
    this.collapseProgress = 0.0,
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
    final logoUrl = (profile?.avatarUrl?.trim().isNotEmpty ?? false)
        ? profile!.avatarUrl!.trim()
        : (profile?.logoUrl?.trim().isNotEmpty ?? false)
            ? profile!.logoUrl!.trim()
            : null;
    final brandName = profile?.brandName ?? 'Brand';
    final category = profile?.brandCategory ?? 'General';

    return Row(
      children: [
        if (showBrandIdentity) ...[
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Opacity(
                  opacity: 1.0 - collapseProgress,
                  child: Row(
                    children: [
                      _BrandLogoMark(
                        label: avatarLabel,
                        logoUrl: logoUrl,
                        width: 48,
                        height: 48,
                        borderRadius: 18,
                        textStyle: AppTypography.labelLG,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${_getGreeting()},',
                                style: AppTypography.bodySM
                                    .copyWith(color: AppColors.muted)),
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
                            Text(category,
                                style: AppTypography.bodyXS
                                    .copyWith(color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Opacity(
                  opacity: collapseProgress,
                  child: _BrandLogoMark(
                    label: avatarLabel,
                    logoUrl: logoUrl,
                    width: 40,
                    height: 40,
                    borderRadius: 12,
                    textStyle: AppTypography.labelMD,
                  ),
                ),
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

class _BrandLogoMark extends StatelessWidget {
  const _BrandLogoMark({
    required this.label,
    required this.logoUrl,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.textStyle,
  });

  final String label;
  final String? logoUrl;
  final double width;
  final double height;
  final double borderRadius;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(
        label,
        style: textStyle.copyWith(
          color: AppColors.brandDark,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.16)),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: logoUrl == null
          ? fallback
          : Image.network(
              logoUrl!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            ),
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
            border:
                Border.all(color: AppColors.brandDark.withValues(alpha: 0.14)),
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
