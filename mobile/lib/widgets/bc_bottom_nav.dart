import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/route_names.dart';
import '../core/theme/app_typography.dart';

enum BCPortalRole { creator, brand }

class BCPageSwipeArea extends StatefulWidget {
  const BCPageSwipeArea({
    super.key,
    required this.role,
    required this.currentIndex,
    required this.child,
  });

  final BCPortalRole role;
  final int currentIndex;
  final Widget child;

  @override
  State<BCPageSwipeArea> createState() => _BCPageSwipeAreaState();
}

class _BCPageSwipeAreaState extends State<BCPageSwipeArea> {
  double _dragDx = 0;
  Duration _animationDuration = Duration.zero;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _animationDuration = Duration.zero;
      _dragDx += details.delta.dx;
    });
  }

  void _handleDragEnd(DragEndDetails details, double width) {
    final velocity = details.primaryVelocity ?? 0;
    final routes = _routesFor(widget.role);
    final maxIndex = routes.length - 1;

    final shouldMoveByDistance = _dragDx.abs() > width * 0.22;
    final shouldMoveByVelocity = velocity.abs() > 450;

    var targetIndex = widget.currentIndex;
    if (shouldMoveByDistance || shouldMoveByVelocity) {
      if (_dragDx < 0 || velocity < 0) {
        targetIndex = (widget.currentIndex + 1).clamp(0, maxIndex);
      } else {
        targetIndex = (widget.currentIndex - 1).clamp(0, maxIndex);
      }
    }

    if (targetIndex == widget.currentIndex) {
      setState(() {
        _animationDuration = const Duration(milliseconds: 220);
        _dragDx = 0;
      });
      return;
    }

    final slideOutDx = targetIndex > widget.currentIndex ? -width : width;
    setState(() {
      _animationDuration = const Duration(milliseconds: 150);
      _dragDx = slideOutDx;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      context.go(routes[targetIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: (details) =>
              _handleDragEnd(details, constraints.maxWidth),
          child: AnimatedContainer(
            duration: _animationDuration,
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(_dragDx, 0, 0),
            child: widget.child,
          ),
        );
      },
    );
  }
}

List<String> _routesFor(BCPortalRole role) {
  switch (role) {
    case BCPortalRole.creator:
      return const [
        RouteNames.creatorHome,
        RouteNames.creatorCampaigns,
        RouteNames.myBids,
        RouteNames.creatorProfile,
      ];
    case BCPortalRole.brand:
      return const [
        RouteNames.brandHome,
        RouteNames.brandCampaigns,
        RouteNames.brandRequests,
        RouteNames.brandProfile,
      ];
  }
}

class BCBottomNav extends StatefulWidget {
  const BCBottomNav({
    super.key,
    required this.role,
    required this.currentIndex,
  });

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

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final itemWidth = width / items.length;
            final capsuleWidth = itemWidth - 6;
            final targetCenterX =
                _dragX ?? (widget.currentIndex * itemWidth + itemWidth / 2);
            final capsuleLeft = (targetCenterX - capsuleWidth / 2)
                .clamp(3.0, width - capsuleWidth - 3.0)
                .toDouble();
            final isDragging = _dragX != null;

            return GestureDetector(
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: (_) => _onDragEnd(items, width, context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    key: _navKey,
                    height: 66,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.84),
                          Colors.black.withValues(alpha: 0.66),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.26),
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
                          top: 5,
                          width: capsuleWidth,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.44),
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
                                  borderRadius: BorderRadius.circular(30),
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
    final routes = _routesFor(role);
    switch (role) {
      case BCPortalRole.creator:
        return [
          _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              route: routes[0]),
          _NavItem(
              icon: Icons.explore_rounded,
              label: 'Campaigns',
              route: routes[1]),
          _NavItem(
              icon: Icons.bookmark_rounded,
              label: 'My Bids',
              route: routes[2]),
          _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              route: routes[3]),
        ];
      case BCPortalRole.brand:
        return [
          _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              route: routes[0]),
          _NavItem(
              icon: Icons.campaign_rounded,
              label: 'Campaigns',
              route: routes[1]),
          _NavItem(
              icon: Icons.send_rounded,
              label: 'Requests',
              route: routes[2]),
          _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              route: routes[3]),
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
