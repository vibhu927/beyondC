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
import 'route_names.dart';

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

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final isAuthenticated = authState.user != null;
      final isAuthRoute = [
        RouteNames.splash,
        RouteNames.onboarding,
        RouteNames.roleSelect,
        RouteNames.signup,
        RouteNames.login,
      ].contains(state.matchedLocation);

      // Not logged in → send to onboarding
      if (!isAuthenticated && !isAuthRoute) return RouteNames.onboarding;

      // Logged in → don't show auth screens
      if (isAuthenticated && isAuthRoute) {
        final role = authState.role;
        return role == 'creator' ? RouteNames.creatorHome : RouteNames.brandHome;
      }

      // Role-based route protection
      if (isAuthenticated) {
        final role = authState.role;
        final location = state.matchedLocation;
        if (role == 'creator' && location.startsWith('/brand')) return RouteNames.creatorHome;
        if (role == 'brand' && location.startsWith('/creator')) return RouteNames.brandHome;
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
        builder: (c, s) => const PlaceholderScreen('Creator Home'),
      ),
      GoRoute(
        path: RouteNames.creatorCampaigns,
        builder: (c, s) => const PlaceholderScreen('Campaigns'),
      ),
      GoRoute(
        path: RouteNames.myBids,
        builder: (c, s) => const PlaceholderScreen('My Bids'),
      ),
      GoRoute(
        path: RouteNames.creatorProfile,
        builder: (c, s) => const PlaceholderScreen('Creator Profile'),
      ),
      GoRoute(
        path: RouteNames.creatorWallet,
        builder: (c, s) => const PlaceholderScreen('Wallet'),
      ),
      GoRoute(
        path: RouteNames.myTickets,
        builder: (c, s) => const PlaceholderScreen('My Tickets'),
      ),

      // Brand Portal
      GoRoute(
        path: RouteNames.brandHome,
        builder: (c, s) => const PlaceholderScreen('Brand Home'),
      ),
      GoRoute(
        path: RouteNames.brandCampaigns,
        builder: (c, s) => const PlaceholderScreen('Brand Campaigns'),
      ),
      GoRoute(
        path: RouteNames.createCampaign,
        builder: (c, s) => const PlaceholderScreen('Create Campaign'),
      ),
      GoRoute(
        path: RouteNames.brandProfile,
        builder: (c, s) => const PlaceholderScreen('Brand Profile'),
      ),
      GoRoute(
        path: RouteNames.brandCredits,
        builder: (c, s) => const PlaceholderScreen('Credits'),
      ),
      GoRoute(
        path: RouteNames.brandEvents,
        builder: (c, s) => const PlaceholderScreen('Events'),
      ),

      // Shared
      GoRoute(
        path: RouteNames.notifications,
        builder: (c, s) => const PlaceholderScreen('Notifications'),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (c, s) => const PlaceholderScreen('Settings'),
      ),
    ],
  );
});
