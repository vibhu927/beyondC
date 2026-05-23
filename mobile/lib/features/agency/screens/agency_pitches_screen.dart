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
import '../../../widgets/agency_page_layout.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/cards/bc_card.dart';

class AgencyPitchesScreen extends ConsumerStatefulWidget {
  const AgencyPitchesScreen({super.key});

  @override
  ConsumerState<AgencyPitchesScreen> createState() =>
      _AgencyPitchesScreenState();
}

class _AgencyPitchesScreenState extends ConsumerState<AgencyPitchesScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  double _scrollOffset = 0;
  late TabController _tabController;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (mounted) setState(() => _scrollOffset = _scrollController.offset);
    });
    _tabController = TabController(length: 2, vsync: this);
    Future<void>.microtask(() {
      ref.read(agencyPitchesProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(agencyPitchesProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness;
    final navClearance = MediaQuery.of(context).padding.bottom + 104;
    final topInset = MediaQuery.of(context).padding.top + 14;
    const headerHeight = 48.0;
    const headerGap = 34.0;
    final sheetTop = topInset + headerHeight + headerGap + 16;

    final surface =
        theme == Brightness.dark ? AppColors.darkSurface : AppColors.white;
    final muted =
        theme == Brightness.dark ? AppColors.darkMuted : AppColors.gray;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar:
          const BCBottomNav(role: BCPortalRole.agency, currentIndex: 2),
      body: AgencyPageLayout(
        scrollOffset: _scrollOffset,
        child: BCPageSwipeArea(
          role: BCPortalRole.agency,
          currentIndex: 2,
          child: Container(
            margin: EdgeInsets.only(top: sheetTop),
            decoration: BoxDecoration(
              color: surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
              border: const Border(
                  top: BorderSide(color: AppColors.agencyDark, width: 2.2)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    30,
                    AppSpacing.screenPadding,
                    0,
                  ),
                  child: Row(
                    children: [
                      Text('Pitches',
                          style: AppTypography.displaySM.copyWith(
                            color: AppColors.agencyDark,
                            fontWeight: FontWeight.w900,
                          )),
                      const Spacer(),
                      _StatusFilterChips(
                        currentFilter: _filterStatus,
                        onChanged: (f) => setState(() => _filterStatus = f),
                        muted: muted,
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.agencyPrimary,
                  labelColor: AppColors.agencyDark,
                  unselectedLabelColor: muted,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Sent'),
                    Tab(text: 'Received'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _SentPitchesTab(
                        scrollController: _scrollController,
                        filterStatus: _filterStatus,
                        onRefresh: _refresh,
                        onShowAll: () => context.push(RouteNames.agencyPitches),
                      ),
                      _ReceivedPitchesTab(
                        scrollController: _scrollController,
                        onRefresh: _refresh,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusFilterChips extends StatelessWidget {
  const _StatusFilterChips(
      {required this.currentFilter,
      required this.onChanged,
      required this.muted});

  final String currentFilter;
  final ValueChanged<String> onChanged;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MiniFilterChip(
          label: 'All',
          isSelected: currentFilter == 'all',
          onTap: () => onChanged('all'),
        ),
        const SizedBox(width: 4),
        _MiniFilterChip(
          label: 'Pending',
          isSelected: currentFilter == 'pending',
          onTap: () => onChanged('pending'),
        ),
        const SizedBox(width: 4),
        _MiniFilterChip(
          label: 'Active',
          isSelected: currentFilter == 'accepted',
          onTap: () => onChanged('accepted'),
        ),
      ],
    );
  }
}

class _MiniFilterChip extends StatelessWidget {
  const _MiniFilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.agencyDark : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.agencyDark
                : AppColors.agencyDark.withValues(alpha: 0.2),
          ),
        ),
        child: Text(label,
            style: AppTypography.labelXS.copyWith(
              color: isSelected ? AppColors.white : AppColors.agencyDark,
              fontWeight: FontWeight.w700,
            )),
      ),
    );
  }
}

class _SentPitchesTab extends ConsumerWidget {
  const _SentPitchesTab(
      {required this.scrollController,
      required this.filterStatus,
      required this.onRefresh,
      required this.onShowAll});

  final ScrollController scrollController;
  final String filterStatus;
  final VoidCallback onRefresh;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pitchesState = ref.watch(agencyPitchesProvider);
    final pitches = pitchesState.valueOrNull ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final muted = isDark ? AppColors.darkMuted : AppColors.gray;

    final sentToCreators =
        pitches.where((p) => p['creator_id'] != null).toList();
    final sentToBrands = pitches.where((p) => p['brand_id'] != null).toList();

    final filteredToCreators = filterStatus == 'all'
        ? sentToCreators
        : sentToCreators.where((p) => p['status'] == filterStatus).toList();
    final filteredToBrands = filterStatus == 'all'
        ? sentToBrands
        : sentToBrands.where((p) => p['status'] == filterStatus).toList();

    final isEmpty = filteredToCreators.isEmpty && filteredToBrands.isEmpty;

    return BCLoadingOverlay(
      isLoading: pitchesState.isLoading,
      child: RefreshIndicator(
        color: AppColors.agencyPrimary,
        onRefresh: () async => onRefresh(),
        child: isEmpty
            ? _EmptyPitchesState(
                title: 'No pitches sent yet',
                subtitle: 'Pitch creators or brands to start collaborating',
                actionLabel: 'Find Creators',
                onAction: () => context.push(RouteNames.agencyDiscover),
                muted: muted,
              )
            : ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                  AppSpacing.screenPadding,
                  AppSpacing.huge,
                ),
                children: [
                  if (filteredToCreators.isNotEmpty) ...[
                    _SectionHeader(
                        title: 'To Creators',
                        count: filteredToCreators.length,
                        muted: muted),
                    const SizedBox(height: AppSpacing.sm),
                    ...filteredToCreators.map((pitch) => _PitchCard(
                          pitch: pitch,
                          direction: 'creator',
                          onTap: () =>
                              _showPitchDetails(context, pitch, 'creator'),
                        )),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (filteredToBrands.isNotEmpty) ...[
                    _SectionHeader(
                        title: 'To Brands',
                        count: filteredToBrands.length,
                        muted: muted),
                    const SizedBox(height: AppSpacing.sm),
                    ...filteredToBrands.map((pitch) => _PitchCard(
                          pitch: pitch,
                          direction: 'brand',
                          onTap: () =>
                              _showPitchDetails(context, pitch, 'brand'),
                        )),
                  ],
                ],
              ),
      ),
    );
  }

  void _showPitchDetails(
      BuildContext context, Map<String, dynamic> pitch, String direction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PitchDetailSheet(pitch: pitch, direction: direction),
    );
  }
}

class _ReceivedPitchesTab extends ConsumerWidget {
  const _ReceivedPitchesTab(
      {required this.scrollController, required this.onRefresh});

  final ScrollController scrollController;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final muted = isDark ? AppColors.darkMuted : AppColors.gray;
    final text = isDark ? AppColors.darkText : AppColors.black;

    return RefreshIndicator(
      color: AppColors.agencyPrimary,
      onRefresh: () async => onRefresh(),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          AppSpacing.huge,
        ),
        children: [
          _ReceivedPitchCard(
            title: 'Coming Soon',
            subtitle:
                'Brands and creators will pitch to you here once they discover your agency.',
            icon: Symbols.inbox_rounded,
            muted: muted,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'When a creator or brand pitches your agency, it will appear here. '
            'You can accept or decline each pitch.',
            style: AppTypography.bodyXS.copyWith(color: muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ReceivedPitchCard extends StatelessWidget {
  const _ReceivedPitchCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.muted,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.agencyPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppColors.agencyPrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon,
              size: 48, color: AppColors.agencyDark.withValues(alpha: 0.4)),
          const SizedBox(height: AppSpacing.md),
          Text(title,
              style: AppTypography.labelLG.copyWith(
                  color: AppColors.agencyDark, fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle,
              style: AppTypography.bodyXS.copyWith(color: muted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.title, required this.count, required this.muted});

  final String title;
  final int count;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: AppTypography.labelLG.copyWith(color: AppColors.agencyDark)),
        const SizedBox(width: AppSpacing.sm),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.agencyPrimary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text('$count',
                style: AppTypography.labelXS.copyWith(
                    color: AppColors.agencyDark, fontWeight: FontWeight.w700)),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _PitchCard extends StatelessWidget {
  const _PitchCard(
      {required this.pitch, required this.direction, required this.onTap});

  final Map<String, dynamic> pitch;
  final String direction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = isDark ? AppColors.darkText : AppColors.black;
    final muted = isDark ? AppColors.darkMuted : AppColors.gray;

    final status = pitch['status'] ?? 'pending';
    final title = pitch['pitch_title'] ?? 'Pitch';
    final message = pitch['pitch_message'] ?? pitch['pitch_description'] ?? '';
    final statusColor = _getStatusColor(status);
    final isCreator = direction == 'creator';
    final target =
        isCreator ? pitch['creator_profile'] : pitch['creator_profile'];
    final targetName = target?['first_name'] ??
        target?['full_name'] ??
        (isCreator ? 'Creator' : 'Brand');
    final targetAvatar = target?['avatar_url'];
    final monthlyFee = pitch['monthly_fee'];
    final profitRatio = pitch['profit_ratio'];
    final createdAt = pitch['created_at'];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BCCard(
        onTap: onTap,
        backgroundColor: surface,
        borderColor: outline,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.agencyDark.withValues(alpha: 0.15),
                  backgroundImage:
                      targetAvatar != null ? NetworkImage(targetAvatar) : null,
                  child: targetAvatar == null
                      ? const Icon(Icons.person,
                          color: AppColors.agencyDark, size: 16)
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(targetName,
                          style: AppTypography.labelMD.copyWith(color: text)),
                      Text(isCreator ? 'To Creator' : 'To Brand',
                          style: AppTypography.labelXS.copyWith(color: muted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toString().toUpperCase(),
                    style: AppTypography.labelXS.copyWith(
                        color: statusColor, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title,
                style: AppTypography.labelLG.copyWith(color: text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(message,
                  style: AppTypography.bodyXS.copyWith(color: muted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (monthlyFee != null) ...[
                  Icon(Symbols.currency_rupee_rounded, size: 12, color: muted),
                  const SizedBox(width: 2),
                  Text('₹$monthlyFee/mo',
                      style: AppTypography.labelXS.copyWith(color: muted)),
                  const SizedBox(width: AppSpacing.md),
                ],
                if (profitRatio != null) ...[
                  Icon(Symbols.percent_rounded, size: 12, color: muted),
                  const SizedBox(width: 2),
                  Text('$profitRatio%',
                      style: AppTypography.labelXS.copyWith(color: muted)),
                ],
                const Spacer(),
                if (createdAt != null) ...[
                  Text(_formatDate(createdAt),
                      style: AppTypography.labelXS.copyWith(color: muted)),
                  const SizedBox(width: 4),
                  const Icon(Symbols.arrow_forward_rounded,
                      size: 14, color: AppColors.agencyDark),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'accepted' => AppColors.success,
      'rejected' => AppColors.error,
      'pending' => AppColors.warning,
      _ => AppColors.muted,
    };
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final d = DateTime.parse(date.toString());
      final now = DateTime.now();
      final diff = now.difference(d);
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${d.day}/${d.month}';
    } catch (_) {
      return '';
    }
  }
}

class _PitchDetailSheet extends StatelessWidget {
  const _PitchDetailSheet({required this.pitch, required this.direction});

  final Map<String, dynamic> pitch;
  final String direction;

  @override
  Widget build(BuildContext context) {
    final status = pitch['status'] ?? 'pending';
    final title = pitch['pitch_title'] ?? 'Pitch';
    final message = pitch['pitch_message'] ?? pitch['pitch_description'] ?? '';
    final monthlyFee = pitch['monthly_fee'];
    final profitRatio = pitch['profit_ratio'];
    final proposedAmount = pitch['proposed_amount'];
    final collabType = pitch['collab_type'];
    final deliverables = pitch['deliverables'];
    final isCreator = direction == 'creator';
    final target =
        isCreator ? pitch['creator_profile'] : pitch['creator_profile'];
    final targetName = target?['first_name'] ??
        target?['full_name'] ??
        (isCreator ? 'Creator' : 'Brand');
    final targetAvatar = target?['avatar_url'];
    final statusColor = _getStatusColor(status);

    return _AgencySheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.agencyDark.withValues(alpha: 0.2),
                backgroundImage:
                    targetAvatar != null ? NetworkImage(targetAvatar) : null,
                child: targetAvatar == null
                    ? const Icon(Icons.person, color: AppColors.agencyDark)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(targetName,
                        style: AppTypography.displaySM.copyWith(
                            color: AppColors.agencyDark,
                            fontWeight: FontWeight.w900)),
                    Text(isCreator ? 'Pitched to Creator' : 'Pitched to Brand',
                        style: AppTypography.bodyXS
                            .copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status.toString().toUpperCase(),
                    style: AppTypography.labelSM.copyWith(
                        color: statusColor, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(title,
              style: AppTypography.labelLG.copyWith(
                  color: AppColors.agencyDark, fontWeight: FontWeight.w900)),
          if (message.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(message,
                style: AppTypography.bodySM.copyWith(color: AppColors.muted)),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              if (monthlyFee != null)
                _DetailChip(
                    icon: Icons.currency_rupee, label: '₹$monthlyFee/month'),
              if (profitRatio != null)
                _DetailChip(icon: Icons.percent, label: '$profitRatio% profit'),
              if (proposedAmount != null)
                _DetailChip(
                    icon: Icons.currency_rupee, label: '₹$proposedAmount'),
              if (collabType != null)
                _DetailChip(
                    icon: Icons.handshake, label: collabType.toString()),
            ],
          ),
          if (deliverables != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Symbols.task_alt_rounded,
                    color: AppColors.muted, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Deliverables: $deliverables',
                    style:
                        AppTypography.labelXS.copyWith(color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          _SheetPrimaryButton(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'accepted' => AppColors.success,
      'rejected' => AppColors.error,
      'pending' => AppColors.warning,
      _ => AppColors.muted,
    };
  }
}

class _AgencySheetShell extends StatelessWidget {
  const _AgencySheetShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: AppColors.agencyDark.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.md,
            AppSpacing.screenPadding,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.agencyDark.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetPrimaryButton extends StatelessWidget {
  const _SheetPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isFullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Container(
          width: isFullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.agencyDark
                : AppColors.agencyDark.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelMD.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.agencyPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.agencyPrimary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.agencyPrimary),
          const SizedBox(width: 4),
          Text(label,
              style: AppTypography.labelXS
                  .copyWith(color: AppColors.agencyPrimary)),
        ],
      ),
    );
  }
}

class _EmptyPitchesState extends StatelessWidget {
  const _EmptyPitchesState({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    required this.muted,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.screenPadding),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.send_rounded,
                size: 56, color: AppColors.agencyDark.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text(title,
                style: AppTypography.labelLG.copyWith(
                    color: AppColors.agencyDark, fontWeight: FontWeight.w900)),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle,
                style: AppTypography.bodySM.copyWith(color: muted),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            UnconstrainedBox(
              child: _SheetPrimaryButton(
                label: actionLabel,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
