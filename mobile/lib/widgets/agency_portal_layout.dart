import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bc_bottom_nav.dart';
import '../../widgets/bc_portal_top_bar.dart';

const _agencyRoutes = [
  RouteNames.agencyHome,
  RouteNames.agencyDiscover,
  RouteNames.agencyPitches,
  RouteNames.agencyPartnered,
  RouteNames.agencyProfile,
];

class AgencyPortalLayout extends ConsumerWidget {
  const AgencyPortalLayout({
    super.key,
    required this.child,
  });

  final Widget child;

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _agencyRoutes.indexWhere((route) => location.startsWith(route));
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _getCurrentIndex(context);
    
    return Scaffold(
      extendBody: true,
      appBar: const BCPortalTopBar(),
      bottomNavigationBar: BCBottomNav(
        role: BCPortalRole.agency,
        currentIndex: currentIndex,
      ),
      body: child,
    );
  }
}

class AgencyPageWrapper extends StatelessWidget {
  const AgencyPageWrapper({
    super.key,
    required this.tabIndex,
    required this.child,
  });

  final int tabIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isOnTab = _agencyRoutes[tabIndex] == currentLocation ||
        (tabIndex == 0 && currentLocation == RouteNames.agencyHome);

    if (!isOnTab) {
      return child;
    }

    return AgencyPortalLayout(child: child);
  }
}