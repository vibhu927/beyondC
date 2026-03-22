import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/route_names.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

enum BCPortalRole { creator, brand }

class BCBottomNav extends StatelessWidget {
  const BCBottomNav({
    super.key,
    required this.role,
    required this.currentIndex,
  });

  final BCPortalRole role;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final items = _itemsFor(role);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final divider = theme.dividerTheme.color ??
        (isDark ? AppColors.darkDivider : AppColors.lightDivider);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: divider)),
      ),
      child: Theme(
        data: theme.copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: surface,
            indicatorColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            labelTextStyle:
                WidgetStateProperty.resolveWith<TextStyle>((states) {
              final isSelected = states.contains(WidgetState.selected);
              return AppTypography.labelXS.copyWith(
                color:
                    isSelected ? onSurface : onSurface.withValues(alpha: 0.6),
              );
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            if (index == currentIndex) return;
            context.go(items[index].route);
          },
          destinations: [
            for (var i = 0; i < items.length; i++)
              NavigationDestination(
                icon: _NavIcon(
                  icon: items[i].icon,
                  isSelected: false,
                  isDark: isDark,
                  onSurfaceColor: onSurface,
                ),
                selectedIcon: _NavIcon(
                  icon: items[i].icon,
                  isSelected: true,
                  isDark: isDark,
                  onSurfaceColor: onSurface,
                ),
                label: items[i].label,
              ),
          ],
        ),
      ),
    );
  }

  List<_NavItem> _itemsFor(BCPortalRole role) {
    switch (role) {
      case BCPortalRole.creator:
        return const [
          _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              route: RouteNames.creatorHome),
          _NavItem(
              icon: Icons.explore_rounded,
              label: 'Campaigns',
              route: RouteNames.creatorCampaigns),
          _NavItem(
              icon: Icons.bookmark_rounded,
              label: 'My Bids',
              route: RouteNames.myBids),
          _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              route: RouteNames.creatorProfile),
        ];
      case BCPortalRole.brand:
        return const [
          _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              route: RouteNames.brandHome),
          _NavItem(
              icon: Icons.campaign_rounded,
              label: 'Campaigns',
              route: RouteNames.brandCampaigns),
          _NavItem(
              icon: Icons.send_rounded,
              label: 'Requests',
              route: RouteNames.brandRequests),
          _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              route: RouteNames.brandProfile),
        ];
    }
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onSurfaceColor,
  });

  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final Color onSurfaceColor;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 22,
      color: isSelected
          ? AppColors.lightText
          : onSurfaceColor.withValues(alpha: 0.6),
    );

    if (!isSelected) return iconWidget;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.neon,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        border:
            isDark ? Border.all(color: AppColors.darkBorder, width: 1) : null,
      ),
      child: iconWidget,
    );
  }
}
