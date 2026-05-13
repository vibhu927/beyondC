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
      backgroundColor: const Color(0xFFF5F5F0),
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
              // Agency Card
              AnimatedScale(
                scale: _selectedRole == 'agency' ? 1.01 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: GestureDetector(
                  onTap: () => _selectRole('agency'),
                  child: BCCard(
                    shadow: _selectedRole == 'agency'
                        ? AppShadows.blue
                        : AppShadows.blue,
                    borderColor: _selectedRole == 'agency'
                        ? AppColors.blue
                        : AppColors.ink,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BCBadge(
                                label: 'For Agencies',
                                variant: BCBadgeVariant.blue,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Agency / Manager 🤝',
                                style: AppTypography.displaySM.copyWith(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Manage creators and pitch brands on their behalf.',
                                style: AppTypography.bodySM.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: [
                                  BCBadge(
                                    label: 'Talent Manager',
                                    variant: BCBadgeVariant.outline,
                                  ),
                                  BCBadge(
                                    label: 'Creator Agency',
                                    variant: BCBadgeVariant.outline,
                                  ),
                                  BCBadge(
                                    label: 'MCN',
                                    variant: BCBadgeVariant.outline,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          '🤝',
                          style: TextStyle(fontSize: 48),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Or Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.ink.withValues(alpha: 0.15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: AppTypography.bodySM.copyWith(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.ink.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Login Card
              GestureDetector(
                onTap: () => context.push(RouteNames.login),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                    horizontal: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.ink, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Already have an account? Log in',
                          style: AppTypography.labelMD.copyWith(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.purple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ],
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
