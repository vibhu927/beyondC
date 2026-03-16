import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/route_names.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/notification_provider.dart';
import '../providers/theme_provider.dart';

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
    final unreadCount = ref.watch(
      notificationProvider.select((state) => state.unreadCount),
    );
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final iconColor = isDark ? AppColors.white : AppColors.ink;
    final appBarColor = isDark ? AppColors.ink : AppColors.white;
    final borderColor = isDark ? const Color(0xFF2A2A2A) : AppColors.divider;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: appBarColor,
      titleSpacing: 20,
      title: Text(title,
          style: AppTypography.displaySM.copyWith(color: iconColor)),
      actions: [
        ...?actions,
        IconButton(
          onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: iconColor,
          ),
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => context.go(RouteNames.notifications),
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: iconColor,
                ),
                tooltip: 'Notifications',
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      shape: Border(
        bottom: BorderSide(color: borderColor),
      ),
    );
  }
}
