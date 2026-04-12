import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/route_names.dart';

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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
                borderRadius: BorderRadius.circular(34),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    key: _navKey,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0D131C),
                          const Color(0xFF121A25),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.24),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
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
                          top: 6,
                          width: capsuleWidth,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.34),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.32),
                                width: 1.0,
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
              icon: Icons.inbox_rounded,
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
    final color = isSelected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.72);

    return Center(
      child: Icon(
        icon,
        size: 30,
        color: color,
      ),
    );
  }
}
