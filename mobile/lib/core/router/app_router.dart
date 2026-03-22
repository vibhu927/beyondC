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
import '../../features/brand/screens/credits_screen.dart';
import '../../features/creator/screens/creator_home_screen.dart';
import '../../features/creator/screens/campaigns_screen.dart';
import '../../features/creator/screens/campaign_detail_screen.dart';
import '../../features/creator/screens/my_tickets_screen.dart';
import '../../features/creator/screens/profile_screen.dart';
import '../../features/creator/screens/ticket_detail_screen.dart';
import '../../features/creator/screens/wallet_screen.dart';
import '../../features/shared/screens/chat_screen.dart';
import '../../features/shared/screens/collab_detail_screen.dart';
import '../../features/shared/screens/milestone_screen.dart';
import '../../features/shared/screens/notifications_screen.dart';
import '../../features/shared/screens/rating_screen.dart';
import 'route_names.dart';
import 'router_holder.dart';

// Placeholder screen widgets — replace as screens are built
class PlaceholderScreen extends StatelessWidget {
  final String name;
  const PlaceholderScreen(this.name, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(name)),
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
    initialLocation: RouteNames.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
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
        builder: (c, s) => const CreatorHomeScreen(),
      ),
      GoRoute(
        path: RouteNames.creatorCampaigns,
        builder: (c, s) => const CampaignsScreen(),
      ),
      GoRoute(
        path: RouteNames.campaignDetail,
        builder: (c, s) => CampaignDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteNames.myBids,
        builder: (c, s) => const PlaceholderScreen('My Bids'),
      ),
      GoRoute(
        path: RouteNames.creatorRequests,
        builder: (c, s) => const PlaceholderScreen('Creator Requests'),
      ),
      GoRoute(
        path: RouteNames.creatorCollabs,
        builder: (c, s) => const PlaceholderScreen('Creator Collabs'),
      ),
      GoRoute(
        path: RouteNames.creatorChat,
        builder: (c, s) => ChatScreen(collabId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteNames.creatorEvents,
        builder: (c, s) => const PlaceholderScreen('Creator Events'),
      ),
      GoRoute(
        path: RouteNames.creatorProfile,
        builder: (c, s) => const CreatorProfileScreen(),
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
        builder: (c, s) => const BrandHomeScreen(),
      ),
      GoRoute(
        path: RouteNames.brandCampaigns,
        builder: (c, s) => const BrandCampaignsScreen(),
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
        builder: (c, s) => const PlaceholderScreen('Brand Requests'),
      ),
      GoRoute(
        path: RouteNames.brandChat,
        builder: (c, s) => ChatScreen(collabId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteNames.brandProfile,
        builder: (c, s) => const BrandProfileScreen(),
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
    ],
  );

  RouterHolder.router = router;
  return router;
});
