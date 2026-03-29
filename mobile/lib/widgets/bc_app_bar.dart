import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/route_names.dart';
import '../core/theme/app_colors.dart';
import '../providers/chat_modal_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/theme_provider.dart';
import 'chat_modal/chat_modal.dart';

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
    final unreadChats = ref.watch(chatModalUnreadCountProvider);

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
              Icons.mark_chat_unread_rounded,
              color: isDark ? AppColors.darkText : AppColors.ink,
            ),
            onPressed: () => _openChatModal(context),
          ),
          if (unreadChats > 0)
            const Positioned(
              right: 8,
              top: 8,
              child: _DotBadge(),
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
            onPressed: () => context.push(RouteNames.notifications),
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
