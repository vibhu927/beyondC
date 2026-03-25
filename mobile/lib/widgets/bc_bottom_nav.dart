import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/route_names.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

enum BCPortalRole { creator, brand }

class BCBottomNav extends StatefulWidget {
  const BCBottomNav({
    super.key,
    required this.role,
    required this.currentIndex,
  });

  // One color per app launch (static for session), excluding neon/parrot.
  static final Color sessionTint = _palette[Random().nextInt(_palette.length)];

  static const List<Color> _palette = <Color>[
    Color.fromARGB(255, 164, 46, 99),
    Color.fromARGB(255, 95, 51, 171),
    Color.fromARGB(255, 29, 76, 158),
    Color.fromARGB(255, 199, 96, 23),
    Color.fromARGB(255, 192, 49, 82),
    Color.fromARGB(255, 46, 121, 196),
    Color.fromARGB(255, 179, 95, 30),
  ];

  final BCPortalRole role;
  final int currentIndex;

  @override
  State<BCBottomNav> createState() => _BCBottomNavState();
}

class _BCBottomNavState extends State<BCBottomNav> {
  final GlobalKey _navKey = GlobalKey();
  double? _dragX;

  void _onDragUpdate(DragUpdateDetails details) {
    final box = _navKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = box.globalToLocal(details.globalPosition);
    setState(() {
      _dragX = local.dx;
    });
  }

  void _onDragEnd(List<_NavItem> items, double width, BuildContext context) {
    if (_dragX == null || width <= 0) {
      setState(() => _dragX = null);
      return;
    }

    final itemWidth = width / items.length;
    final clamped = _dragX!.clamp(0.0, width - 0.001);
    final targetIndex =
        (clamped / itemWidth).floor().clamp(0, items.length - 1);

    setState(() => _dragX = null);
    if (targetIndex != widget.currentIndex) {
      context.go(items[targetIndex].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _itemsFor(widget.role);
    final tint = BCBottomNav.sessionTint;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final itemWidth = width / items.length;
            final capsuleWidth = itemWidth - 10;
            final targetCenterX =
                _dragX ?? (widget.currentIndex * itemWidth + itemWidth / 2);
            final capsuleLeft = (targetCenterX - capsuleWidth / 2)
                .clamp(5.0, width - capsuleWidth - 5.0)
                .toDouble();
            final isDragging = _dragX != null;

            return GestureDetector(
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: (_) => _onDragEnd(items, width, context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    key: _navKey,
                    height: 74,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          tint.withValues(alpha: 0.32),
                          tint.withValues(alpha: 0.16),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: tint.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: tint.withValues(alpha: 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: isDragging
                              ? Duration.zero
                              : const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          left: capsuleLeft,
                          top: 8,
                          width: capsuleWidth,
                          height: 58,
                          child: Container(
                            decoration: BoxDecoration(
                              color: tint.withValues(alpha: 0.34),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.55),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < items.length; i++)
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () {
                                    if (i == widget.currentIndex) return;
                                    context.go(items[i].route);
                                  },
                                  child: _NavIcon(
                                    icon: items[i].icon,
                                    label: items[i].label,
                                    isSelected: i == widget.currentIndex,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
    required this.label,
    required this.isSelected,
  });

  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? Colors.white : Colors.white.withValues(alpha: 0.82);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 3),
        Text(
          label,
          style: AppTypography.labelXS.copyWith(
            color: color,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
