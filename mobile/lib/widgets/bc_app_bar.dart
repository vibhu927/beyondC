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
    final unreadCount = ref.watch(unreadCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = Theme.of(context).colorScheme.onSurface;
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).dividerTheme.color ??
        (isDark ? AppColors.darkDivider : AppColors.lightDivider);

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
        Consumer(
          builder: (context, ref, _) {
            final toggledDark =
                ref.watch(themeProvider.select((m) => m == ThemeMode.dark));

            return IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? AppColors.neon : iconColor,
              ),
              onPressed: () => ref.read(themeProvider.notifier).toggle(),
              tooltip: toggledDark ? 'Light mode' : 'Dark mode',
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => context.push(RouteNames.notifications),
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: iconColor,
                ),
                tooltip: 'Notifications',
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 6,
                  child: unreadCount > 9
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: appBarColor,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            '9+',
                            style: AppTypography.labelXS.copyWith(
                              color: AppColors.white,
                              fontSize: 9,
                              height: 1,
                            ),
                          ),
                        )
                      : Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: appBarColor,
                              width: 1.5,
                            ),
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
