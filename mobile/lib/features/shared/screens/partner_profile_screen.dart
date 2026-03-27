import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class PartnerProfileScreen extends StatelessWidget {
  const PartnerProfileScreen({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? 'Partner').toString();
    final role = (data['role'] ?? 'creator').toString();
    final tier = (data['tier'] ?? 'N/A').toString();
    final bio = (data['bio'] ?? '').toString();
    final followers = data['followers'];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          role == 'creator' ? 'Creator Profile' : 'Brand Profile',
          style: AppTypography.displaySM,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.xl,
          AppSpacing.screenPadding,
          AppSpacing.huge,
        ),
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink, width: 2),
                ),
                child: Text(
                  _initials(name),
                  style: AppTypography.labelMD,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.displaySM),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      role == 'creator' ? 'Creator' : 'Brand',
                      style: AppTypography.bodySM,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _InfoTile(label: 'Tier', value: tier),
          _InfoTile(
            label: 'Followers',
            value: followers == null ? 'N/A' : followers.toString(),
          ),
          _InfoTile(
            label: 'Bio',
            value: bio.trim().isEmpty ? 'No bio available.' : bio,
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^A-Za-z ]'), '').trim();
    if (cleaned.isEmpty) return 'U';
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          border: Border.all(color: AppColors.lightDivider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.labelSM),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: AppTypography.bodyMD),
          ],
        ),
      ),
    );
  }
}
