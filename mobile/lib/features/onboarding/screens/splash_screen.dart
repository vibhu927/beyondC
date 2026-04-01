import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/bc_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _minimumSplashDuration = Duration(milliseconds: 1800);

  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();

    // Setup bouncing dots animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();

    _animation1 = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -10.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 50,
      ),
    ]).animate(_controller);

    _animation2 = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 16.67,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -10.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 33.33,
      ),
    ]).animate(_controller);

    _animation3 = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 33.33,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -10.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 16.67,
      ),
    ]).animate(_controller);

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(_minimumSplashDuration);

    if (!mounted) return;

    final auth = ref.read(authProvider);

    if (auth.isAuthenticated) {
      // Check if onboarded
      final isOnboarded = await ref.read(authProvider.notifier).isOnboarded();

      if (!mounted) return;

      if (isOnboarded) {
        // Redirect to role-appropriate home
        final role = auth.role;
        if (role == 'creator') {
          context.go(RouteNames.creatorHome);
        } else if (role == 'brand') {
          context.go(RouteNames.brandHome);
        } else {
          context.go(RouteNames.onboarding);
        }
      } else {
        // Not onboarded, go to role select
        context.go(RouteNames.roleSelect);
      }
    } else {
      // Not logged in, go to onboarding
      context.go(RouteNames.onboarding);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BCLogo(isDark: true),
            const SizedBox(height: 16),
            Text(
              'Collabs, but make it Beyond.',
              style: AppTypography.bodyMD.copyWith(
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 60),
            // Bouncing dots loader
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation1,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animation1.value),
                      child: child,
                    );
                  },
                  child: _buildDot(),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _animation2,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animation2.value),
                      child: child,
                    );
                  },
                  child: _buildDot(),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _animation3,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animation3.value),
                      child: child,
                    );
                  },
                  child: _buildDot(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColors.neon,
        shape: BoxShape.circle,
      ),
    );
  }
}
