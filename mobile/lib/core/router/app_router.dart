import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/role_select_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/brand/screens/brand_home_screen.dart';
import '../../features/brand/screens/brand_campaigns_screen.dart';
import '../../features/brand/screens/post_campaign_screen.dart';
import '../../features/brand/screens/campaign_bids_screen.dart';
import '../../features/brand/screens/creator_discovery_screen.dart';
import '../../features/brand/screens/brand_events_screen.dart';
import '../../features/brand/screens/create_event_screen.dart';
import '../../features/brand/screens/event_invites_screen.dart';
import '../../features/brand/screens/brand_profile_screen.dart';
import '../../features/brand/screens/brand_requests_screen.dart';
import '../../features/brand/screens/credits_screen.dart';
import '../../features/creator/screens/creator_home_screen.dart';
import '../../features/creator/screens/creator_requests_screen.dart';
import '../../features/creator/screens/creator_collabs_screen.dart';
import '../../features/creator/screens/creator_events_screen.dart';
import '../../features/creator/screens/campaigns_screen.dart';
import '../../features/creator/screens/campaign_detail_screen.dart';
import '../../features/creator/screens/my_bids_screen.dart';
import '../../features/creator/screens/my_tickets_screen.dart';
import '../../features/creator/screens/profile_screen.dart';
import '../../features/creator/screens/ticket_detail_screen.dart';
import '../../features/creator/screens/wallet_screen.dart';
import '../../features/shared/screens/collab_detail_screen.dart';
import '../../features/shared/screens/milestone_screen.dart';
import '../../features/shared/screens/notifications_screen.dart';
import '../../features/shared/screens/partner_profile_screen.dart';
import '../../features/shared/screens/rating_screen.dart';
import '../../widgets/bc_app_bar.dart';
import 'route_names.dart';
import 'router_holder.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// Placeholder screen widgets — replace as screens are built
class PlaceholderScreen extends StatelessWidget {
  final String name;
  const PlaceholderScreen(this.name, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: BCAppBar(title: name),
        body: Center(child: Text(name)),
      );
}

final routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);

  ref.listen<AuthState>(authProvider, (_, __) {
    notifier.value++;
  });

  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerRefreshProvider);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      // Always allow splash screen so both logged-in and logged-out users
      // see the same startup loading experience.
      if (state.matchedLocation == RouteNames.splash) {
        return null;
      }

      final authState = ref.read(authProvider);
      final isAuthenticated = authState.user != null;
      final isAuthRoute = [
        RouteNames.splash,
        RouteNames.onboarding,
        RouteNames.roleSelect,
        RouteNames.signup,
        RouteNames.login,
        RouteNames.forgotPassword,
      ].contains(state.matchedLocation);

      // Not logged in → send to onboarding
      if (!isAuthenticated && !isAuthRoute) return RouteNames.onboarding;

      // Logged in → don't show auth screens
      if (isAuthenticated && isAuthRoute) {
        final role = authState.role;
        return role == 'creator'
            ? RouteNames.creatorHome
            : RouteNames.brandHome;
      }

      // Role-based route protection
      if (isAuthenticated) {
        final role = authState.role;
        final location = state.matchedLocation;
        if (role == 'creator' && location.startsWith('/brand')) {
          return RouteNames.creatorHome;
        }
        if (role == 'brand' && location.startsWith('/creator')) {
          return RouteNames.brandHome;
        }
      }

      return null;
    },
    routes: [
      // Onboarding + Auth
      GoRoute(
        path: RouteNames.splash,
        builder: (c, s) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (c, s) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.roleSelect,
        builder: (c, s) => const RoleSelectScreen(),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          final role = extra?['role'] as String?;
          return SignupScreen(role: role);
        },
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (c, s) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (c, s) => const ForgotPasswordScreen(),
      ),

      // Creator Portal
      GoRoute(
        path: RouteNames.creatorHome,
        pageBuilder: (c, s) => const NoTransitionPage(
          child: CreatorHomeScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.creatorCampaigns,
        pageBuilder: (c, s) => const NoTransitionPage(
          child: CampaignsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.campaignDetail,
        builder: (c, s) => CampaignDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteNames.myBids,
        pageBuilder: (c, s) => const NoTransitionPage(
          child: MyBidsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.creatorRequests,
        builder: (c, s) => const CreatorRequestsScreen(),
      ),
      GoRoute(
        path: RouteNames.creatorCollabs,
        builder: (c, s) => const CreatorCollabsScreen(),
      ),
      GoRoute(
        path: RouteNames.creatorEvents,
        builder: (c, s) => const CreatorEventsScreen(),
      ),
      GoRoute(
        path: RouteNames.creatorProfile,
        pageBuilder: (c, s) => const NoTransitionPage(
          child: CreatorProfileScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.creatorWallet,
        builder: (c, s) => const WalletScreen(),
      ),
      GoRoute(
        path: RouteNames.myTickets,
        builder: (c, s) => const MyTicketsScreen(),
      ),
      GoRoute(
        path: RouteNames.ticketDetail,
        builder: (c, s) =>
            TicketDetailScreen(inviteId: s.pathParameters['id']!),
      ),

      // Brand Portal
      GoRoute(
        path: RouteNames.brandHome,
        pageBuilder: (c, s) => const NoTransitionPage(
          child: BrandHomeScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.brandCampaigns,
        pageBuilder: (c, s) => const NoTransitionPage(
          child: BrandCampaignsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.campaignBids,
        builder: (c, s) => CampaignBidsScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteNames.createCampaign,
        builder: (c, s) => const PostCampaignScreen(),
      ),
      GoRoute(
        path: RouteNames.brandDiscover,
        builder: (c, s) => const CreatorDiscoveryScreen(),
      ),
      GoRoute(
        path: RouteNames.brandRequests,
        pageBuilder: (c, s) => const NoTransitionPage(
          child: BrandRequestsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.brandProfile,
        pageBuilder: (c, s) => const NoTransitionPage(
          child: BrandProfileScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.brandCredits,
        builder: (c, s) => const CreditsScreen(),
      ),
      GoRoute(
        path: RouteNames.brandEvents,
        builder: (c, s) => const BrandEventsScreen(),
      ),
      GoRoute(
        path: RouteNames.createEvent,
        builder: (c, s) => const CreateEventScreen(),
      ),
      GoRoute(
        path: RouteNames.eventInvites,
        builder: (c, s) => EventInvitesScreen(id: s.pathParameters['id']!),
      ),

      // Shared
      GoRoute(
        path: RouteNames.notifications,
        builder: (c, s) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.collabDetail,
        builder: (c, s) =>
            CollabDetailScreen(collabId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteNames.collabMilestones,
        builder: (c, s) => MilestoneScreen(collabId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteNames.collabRating,
        builder: (c, s) => RatingScreen(collabId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (c, s) => const PlaceholderScreen('Settings'),
      ),
      GoRoute(
        path: RouteNames.partnerProfile,
        builder: (c, s) => PartnerProfileScreen(
          data: (s.extra as Map<String, dynamic>?) ?? const <String, dynamic>{},
        ),
      ),
    ],
  );

  RouterHolder.router = router;
  RouterHolder.rootNavigatorKey = _rootNavigatorKey;
  return router;
});
