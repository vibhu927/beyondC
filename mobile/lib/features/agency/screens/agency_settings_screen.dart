import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/cards/bc_card.dart';

class AgencySettingsScreen extends ConsumerWidget {
  const AgencySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Settings', style: AppTypography.displaySM),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const Text('Appearance', style: AppTypography.displaySM),
          const SizedBox(height: AppSpacing.md),
          _ThemeOption(
            title: 'Light',
            subtitle: 'Always use light theme',
            icon: Icons.light_mode,
            isSelected: themeMode == ThemeMode.light,
            onTap: () => ref.read(themeProvider.notifier).setMode(ThemeMode.light),
          ),
          const SizedBox(height: AppSpacing.md),
          _ThemeOption(
            title: 'Dark',
            subtitle: 'Always use dark theme',
            icon: Icons.dark_mode,
            isSelected: themeMode == ThemeMode.dark,
            onTap: () => ref.read(themeProvider.notifier).setMode(ThemeMode.dark),
          ),
          const SizedBox(height: AppSpacing.md),
          _ThemeOption(
            title: 'System',
            subtitle: 'Follow device settings',
            icon: Icons.settings_suggest,
            isSelected: themeMode == ThemeMode.system,
            onTap: () => ref.read(themeProvider.notifier).setMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.agencyPrimary.withValues(alpha: 0.2)
                  : AppColors.muted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.agencyPrimary : AppColors.muted,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLG),
                Text(
                  subtitle,
                  style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle,
              color: AppColors.agencyPrimary,
            ),
        ],
      ),
    );
  }
}
