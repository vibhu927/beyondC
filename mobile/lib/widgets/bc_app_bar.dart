import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../features/chat/chat_modal.dart';
import '../features/shared/widgets/notifications_modal.dart';
import '../providers/notification_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class BCAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const BCAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    final defaultActions = <Widget>[
      IconButton(
        icon: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: isDark ? AppColors.neon : AppColors.lightText,
        ),
        onPressed: () => ref.read(themeProvider.notifier).toggle(),
        tooltip: isDark ? 'Light mode' : 'Dark mode',
      ),
      Stack(
        children: [
          IconButton(
            icon: Icon(
              Icons.chat_bubble_rounded,
              color: isDark ? AppColors.neon : AppColors.ink,
            ),
            onPressed: () => _openChatModal(context),
            tooltip: 'Messages',
          ),
          if (unreadChats > 0)
            Positioned(
              right: 6,
              top: 6,
              child: _CountBadge(count: unreadChats),
            ),
        ],
      ),
      Stack(
        children: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: isDark ? AppColors.darkText : AppColors.ink,
            ),
            onPressed: () => openNotificationsModal(context),
          ),
          if (unreadNotifications > 0)
            const Positioned(
              right: 8,
              top: 8,
              child: _DotBadge(),
            ),
        ],
      ),
    ];

    final mergedActions = <Widget>[
      ...defaultActions,
      if (actions != null) ...actions!,
    ];

    return AppBar(
      title: Text(title),
      actions: mergedActions,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
    );
  }

  void _openChatModal(BuildContext context) {
    openChatModal(context);
  }
}

class _DotBadge extends StatelessWidget {
  const _DotBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.pink,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.pink,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.white, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
