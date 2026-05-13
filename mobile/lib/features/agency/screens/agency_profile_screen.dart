import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/agency_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/agency_page_layout.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/buttons/bc_action_button.dart';

class AgencyProfileScreen extends ConsumerStatefulWidget {
  const AgencyProfileScreen({super.key});

  @override
  ConsumerState<AgencyProfileScreen> createState() => _AgencyProfileScreenState();
}

class _AgencyProfileScreenState extends ConsumerState<AgencyProfileScreen> {
  final _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (mounted) setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  Future<void> _logout() async {
    try {
      await ref.read(authProvider.notifier).signOut();
      if (!mounted) return;
      context.go(RouteNames.login);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to logout. Please try again.')),
      );
    }
  }

  Future<void> _refresh() async {
    await ref.read(agencyProfileProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness;
    final navClearance = MediaQuery.of(context).padding.bottom + 104;
    final topInset = MediaQuery.of(context).padding.top + 14;
    const headerHeight = 48.0;
    const headerGap = 34.0;
    final sheetTop = topInset + headerHeight + headerGap + 16;

    final surface = theme == Brightness.dark ? AppColors.darkSurface : AppColors.white;
    final muted = theme == Brightness.dark ? AppColors.darkMuted : AppColors.gray;
    final text = theme == Brightness.dark ? AppColors.darkText : AppColors.black;

    final agency = ref.watch(agencyProfileProvider);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const BCBottomNav(role: BCPortalRole.agency, currentIndex: 4),
      body: BCPageSwipeArea(
        role: BCPortalRole.agency,
        currentIndex: 4,
        child: AgencyPageLayout(
          scrollOffset: _scrollOffset,
          child: BCLoadingOverlay(
            isLoading: agency.isLoading,
            child: agency.when(
              loading: () => const SizedBox(),
              error: (e, s) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Symbols.error_rounded, color: AppColors.error, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    const Text('Error loading profile', style: AppTypography.labelLG),
                    const SizedBox(height: AppSpacing.sm),
                    BCActionButton(label: 'Retry', onPressed: _refresh),
                  ],
                ),
              ),
              data: (data) => RefreshIndicator(
                color: AppColors.agencyPrimary,
                onRefresh: _refresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.only(top: sheetTop),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                          border: const Border(top: BorderSide(color: AppColors.agencyDark, width: 2.2)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.screenPadding, AppSpacing.lg,
                            AppSpacing.screenPadding, navClearance,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ProfileHeroCard(data: data, muted: muted),
                              const SizedBox(height: AppSpacing.xl),
                              _StatsRow(data: data, muted: muted, text: text),
                              const SizedBox(height: AppSpacing.xl),
                              Text('Account', style: AppTypography.displaySM.copyWith(
                                color: AppColors.agencyDark, fontWeight: FontWeight.w900,
                              )),
                              const SizedBox(height: AppSpacing.md),
                              _ProfileMenuItem(
                                icon: Symbols.credit_card_rounded,
                                label: 'Credits',
                                subtitle: '${data['credit_balance'] ?? 0} credits available',
                                badge: null,
                                onTap: () => context.push(RouteNames.agencyCredits),
                                text: text,
                                muted: muted,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _ProfileMenuItem(
                                icon: Symbols.groups_rounded,
                                label: 'Roster',
                                subtitle: 'Manage your creator roster',
                                badge: null,
                                onTap: () => context.push(RouteNames.agencyPartnered),
                                text: text,
                                muted: muted,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _ProfileMenuItem(
                                icon: Symbols.send_rounded,
                                label: 'Pitches',
                                subtitle: 'View all your pitches',
                                badge: null,
                                onTap: () => context.push(RouteNames.agencyPitches),
                                text: text,
                                muted: muted,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Text('Settings', style: AppTypography.displaySM.copyWith(
                                color: AppColors.agencyDark, fontWeight: FontWeight.w900,
                              )),
                              const SizedBox(height: AppSpacing.md),
                              _ProfileMenuItem(
                                icon: Symbols.tune_rounded,
                                label: 'Preferences',
                                subtitle: 'Theme, notifications',
                                badge: null,
                                onTap: () => context.push(RouteNames.agencySettings),
                                text: text,
                                muted: muted,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _ProfileMenuItem(
                                icon: Symbols.edit_rounded,
                                label: 'Edit Profile',
                                subtitle: 'Update agency details',
                                badge: null,
                                onTap: () => _showEditProfile(context, data),
                                text: text,
                                muted: muted,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              BCActionButton(
                                label: 'Logout',
                                isFullWidth: true,
                                onPressed: _logout,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ink,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EditProfileSheet(data: data),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.data, required this.muted});

  final Map<String, dynamic> data;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final agencyName = data['agency_name'] ?? data['display_name'] ?? 'Agency';
    final tagline = data['tagline'];
    final description = data['description'];
    final logoUrl = data['logo_url'];
    final isVerified = data['is_agency_verified'] == true;
    final website = data['website'];
    final instagram = data['instagram_handle'];
    final size = data['size'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.agencyPrimary.withValues(alpha: 0.08),
            AppColors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.agencyDark.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.agencyDark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.agencyDark.withValues(alpha: 0.15)),
                  image: logoUrl != null ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover) : null,
                ),
                child: logoUrl == null
                    ? const Icon(Icons.business, color: AppColors.agencyDark, size: 28)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(agencyName, style: AppTypography.displaySM.copyWith(
                            color: AppColors.agencyDark, fontWeight: FontWeight.w900,
                          )),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Symbols.check_rounded, color: AppColors.white, size: 12),
                          ),
                        ],
                      ],
                    ),
                    if (tagline != null)
                      Text(tagline, style: AppTypography.bodyXS.copyWith(color: muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          if (description != null && description.toString().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              description.toString().length > 120
                  ? '${description.toString().substring(0, 120)}...'
                  : description.toString(),
              style: AppTypography.bodyXS.copyWith(color: muted),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              if (size != null)
                _MetaChip(label: size.toString()),
              if (website != null)
                _MetaChip(label: website.toString(), icon: Symbols.language_rounded),
              if (instagram != null)
                _MetaChip(label: '@${instagram.toString()}', icon: Symbols.camera_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.agencyDark.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.agencyDark.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.agencyDark),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppTypography.labelXS.copyWith(color: AppColors.agencyDark)),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data, required this.muted, required this.text});

  final Map<String, dynamic> data;
  final Color muted;
  final Color text;

  @override
  Widget build(BuildContext context) {
    final credits = data['credit_balance'] ?? 0;
    final partneredCount = data['total_partnered_creators'] ?? 0;
    final pendingPitches = data['pending_pitches'] ?? 0;

    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Credits', value: '$credits', icon: Symbols.credit_card_rounded, muted: muted)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatCard(label: 'Roster', value: '$partneredCount', icon: Symbols.groups_rounded, muted: muted)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatCard(label: 'Pending', value: '$pendingPitches', icon: Symbols.schedule_rounded, muted: muted)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.muted});

  final String label;
  final String value;
  final IconData icon;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = isDark ? AppColors.darkText : AppColors.black;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outline),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.agencyDark),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.labelLG.copyWith(color: text, fontWeight: FontWeight.w900)),
          Text(label, style: AppTypography.labelXS.copyWith(color: muted)),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.badge,
    required this.onTap,
    required this.text,
    required this.muted,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final BCBadge? badge;
  final VoidCallback onTap;
  final Color text;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return BCCard(
      onTap: onTap,
      backgroundColor: surface,
      borderColor: outline,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.agencyPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.agencyDark, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: AppTypography.labelLG.copyWith(color: text)),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      badge!,
                    ],
                  ],
                ),
                Text(subtitle, style: AppTypography.bodyXS.copyWith(color: muted)),
              ],
            ),
          ),
          Icon(Symbols.chevron_right_rounded, color: muted, size: 20),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.data});

  final Map<String, dynamic> data;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _taglineController;
  late TextEditingController _descriptionController;
  late TextEditingController _websiteController;
  late TextEditingController _instagramController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data['agency_name'] ?? '');
    _taglineController = TextEditingController(text: widget.data['tagline'] ?? '');
    _descriptionController = TextEditingController(text: widget.data['description'] ?? '');
    _websiteController = TextEditingController(text: widget.data['website'] ?? '');
    _instagramController = TextEditingController(text: widget.data['instagram_handle'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(agencyProfileProvider.notifier).updateProfile({
        'agency_name': _nameController.text.trim(),
        'tagline': _taglineController.text.trim(),
        'description': _descriptionController.text.trim(),
        'website': _websiteController.text.trim(),
        'instagram_handle': _instagramController.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${error.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Edit Profile', style: AppTypography.displaySM.copyWith(color: AppColors.white)),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Symbols.close_rounded, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _EditField(
            controller: _nameController,
            label: 'Agency Name',
            hint: 'Your agency name',
          ),
          const SizedBox(height: AppSpacing.md),
          _EditField(
            controller: _taglineController,
            label: 'Tagline',
            hint: 'Short tagline for your agency',
          ),
          const SizedBox(height: AppSpacing.md),
          _EditField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Tell creators and brands about your agency',
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          _EditField(
            controller: _websiteController,
            label: 'Website',
            hint: 'www.youragency.com',
          ),
          const SizedBox(height: AppSpacing.md),
          _EditField(
            controller: _instagramController,
            label: 'Instagram Handle',
            hint: 'youragency',
          ),
          const SizedBox(height: AppSpacing.xl),
          GestureDetector(
            onTap: _isSaving ? null : _saveProfile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.agencyDark,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.agencyDark.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                      )
                    : Text(
                        'Save Changes',
                        style: AppTypography.labelMD.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMD.copyWith(color: AppColors.white)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.15)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: AppTypography.bodySM.copyWith(color: AppColors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodySM.copyWith(color: AppColors.muted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }
}