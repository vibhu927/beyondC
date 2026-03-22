import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/router/route_names.dart';
import '../../../widgets/bc_logo.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/badges/bc_badge.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String? _selectedRole;

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
    });

    // Navigate to signup with role passed as extra
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      context.push(RouteNames.signup, extra: {'role': role});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              const BCLogo(isDark: false),
              const SizedBox(height: 48),
              // Headline
              Text(
                'I am a...',
                style: AppTypography.displayLG.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 32),
              // Creator Card
              AnimatedScale(
                scale: _selectedRole == 'creator' ? 1.01 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: GestureDetector(
                  onTap: () => _selectRole('creator'),
                  child: BCCard(
                    shadow: _selectedRole == 'creator'
                        ? AppShadows.neon
                        : AppShadows.neon,
                    borderColor: _selectedRole == 'creator'
                        ? AppColors.neon
                        : AppColors.ink,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BCBadge(
                                label: 'For Creators',
                                variant: BCBadgeVariant.neon,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Content Creator 🎨',
                                style: AppTypography.displaySM.copyWith(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'I create content and want to collab with brands for money or products.',
                                style: AppTypography.bodySM.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Row(
                                children: [
                                  BCBadge(
                                    label: 'Nano',
                                    variant: BCBadgeVariant.outline,
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  BCBadge(
                                    label: 'Micro',
                                    variant: BCBadgeVariant.outline,
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  BCBadge(
                                    label: 'Macro',
                                    variant: BCBadgeVariant.outline,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          '🎨',
                          style: TextStyle(fontSize: 48),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Brand Card
              AnimatedScale(
                scale: _selectedRole == 'brand' ? 1.01 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: GestureDetector(
                  onTap: () => _selectRole('brand'),
                  child: BCCard(
                    shadow: _selectedRole == 'brand'
                        ? AppShadows.pink
                        : AppShadows.pink,
                    borderColor: _selectedRole == 'brand'
                        ? AppColors.pink
                        : AppColors.ink,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BCBadge(
                                label: 'For Brands',
                                variant: BCBadgeVariant.pink,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Brand / Startup 🏢',
                                style: AppTypography.displaySM.copyWith(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'I represent a brand and want to find creators for campaigns and events.',
                                style: AppTypography.bodySM.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Row(
                                children: [
                                  BCBadge(
                                    label: 'Startup',
                                    variant: BCBadgeVariant.outline,
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  BCBadge(
                                    label: 'D2C',
                                    variant: BCBadgeVariant.outline,
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  BCBadge(
                                    label: 'Big Brand',
                                    variant: BCBadgeVariant.outline,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          '🏢',
                          style: TextStyle(fontSize: 48),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Already have account
              Center(
                child: TextButton(
                  onPressed: () {
                    context.push(RouteNames.login);
                  },
                  child: Text(
                    'Already have an account? Log in',
                    style: AppTypography.buttonMD.copyWith(
                      color: AppColors.ink,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
