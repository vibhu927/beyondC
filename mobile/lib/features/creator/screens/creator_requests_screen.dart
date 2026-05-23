import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/creator_page_top_header.dart';

String _readString(dynamic value) {
  if (value == null) return '';
  final s = value.toString().trim();
  return s.isEmpty ? '' : s;
}

class CreatorRequestsScreen extends ConsumerStatefulWidget {
  const CreatorRequestsScreen({super.key});

  @override
  ConsumerState<CreatorRequestsScreen> createState() => _CreatorRequestsScreenState();
}

class _CreatorRequestsScreenState extends ConsumerState<CreatorRequestsScreen> {
  int _selectedTab = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(requestsProvider);
    final agencyPitchesAsync = ref.watch(creatorAgencyPitchesProvider);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 3,
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.creator,
        currentIndex: 3,
        child: RefreshIndicator(
          color: AppColors.neon,
          onRefresh: () async {
            if (_selectedTab == 0) {
              await ref.read(requestsProvider.notifier).refresh();
            } else {
              await ref.read(creatorAgencyPitchesProvider.notifier).refresh();
            }
          },
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  MediaQuery.of(context).padding.top + 14,
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    const CreatorPageTopHeader(),
                    const SizedBox(height: AppSpacing.md),
                    _CreatorCardShell(
                      accent: AppColors.neon,
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TabButton(
                              label: 'Brand Requests',
                              isSelected: _selectedTab == 0,
                              onTap: () => _onTabChanged(0),
                            ),
                          ),
                          Expanded(
                            child: _TabButton(
                              label: 'Agency Pitches',
                              isSelected: _selectedTab == 1,
                              onTap: () => _onTabChanged(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _selectedTab = index),
                  children: [
                    _BrandRequestsTab(requestsAsync: requestsAsync),
                    _AgencyPitchesTab(pitchesAsync: agencyPitchesAsync),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreatorCardShell extends StatelessWidget {
  const _CreatorCardShell({
    required this.child,
    required this.accent,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: accent.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.creatorDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.labelMD.copyWith(
            color: isSelected ? AppColors.white : AppColors.creatorDark,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _BrandRequestsTab extends ConsumerWidget {
  const _BrandRequestsTab({required this.requestsAsync});

  final AsyncValue<List<CollabRequest>> requestsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return requestsAsync.when(
      loading: () => const Center(child: BCAppLoader()),
      error: (error, _) => BCErrorState(
        message: error.toString(),
        onRetry: () => ref.read(requestsProvider.notifier).refresh(),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(
            child: BCEmptyState(
              emoji: '📨',
              message: 'No brand requests yet. Brands will reach out soon.',
            ),
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.md,
            AppSpacing.screenPadding,
            AppSpacing.huge,
          ),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == requests.length - 1 ? 0 : AppSpacing.md,
              ),
              child: _BrandRequestCard(request: request),
            );
          },
        );
      },
    );
  }
}

class _BrandRequestCard extends ConsumerWidget {
  const _BrandRequestCard({required this.request});

  final CollabRequest request;

  void _viewDetails(BuildContext context) {
    if (request.campaignId != null && request.campaignId!.isNotEmpty) {
      context.push('${RouteNames.creatorCampaigns}/${request.campaignId}');
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _BrandRequestDetailSheet(request: request),
      );
    }
  }

  void _viewProfile(BuildContext context) {
    context.push(
      RouteNames.partnerProfile,
      extra: {
        'id': request.brandId,
        'role': 'brand',
        'full_name': request.brandName,
        'name': request.brandName,
        'brandCategory': request.brandCategory,
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionLoading = ref.watch(creatorActionsProvider).isLoading;

    return _CreatorCardShell(
      accent: AppColors.neon,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _avatarColor(request.brandInitial),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  request.brandInitial,
                  style: AppTypography.labelMD.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.brandName,
                      style: AppTypography.labelLG.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${request.brandCategory} / ${timeago.format(request.receivedAt)}',
                      style: AppTypography.bodyXS.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              BCBadge(
                label: Formatters.currency(request.budget),
                variant: BCBadgeVariant.neon,
              ),
              BCBadge(
                label: _collabTypeLabel(request.collabType.name),
                variant: _collabTypeVariant(request.collabType.name),
              ),
              BCBadge(
                label: request.status,
                variant: BCBadgeVariant.outline,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _CardActionButton(
                  label: 'View Details',
                  filled: false,
                  onTap: () => _viewDetails(context),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _CardActionButton(
                  label: 'View Profile',
                  filled: false,
                  onTap: () => _viewProfile(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _CardActionButton(
                  label: actionLoading ? 'Please wait...' : 'Accept',
                  filled: true,
                  onTap: actionLoading
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(creatorActionsProvider.notifier)
                                .respondToRequest(
                                  requestId: request.id,
                                  action: 'accept',
                                );
                            await ref.read(requestsProvider.notifier).refresh();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Request accepted!')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _avatarColor(String initial) {
    final colors = [
      AppColors.pink,
      AppColors.purple,
      AppColors.orange,
      AppColors.skyBlue,
    ];
    final index = initial.isNotEmpty ? initial.codeUnitAt(0) % colors.length : 0;
    return colors[index];
  }

  String _collabTypeLabel(String type) {
    switch (type) {
      case ' barter':
        return 'Barter';
      case 'paid':
        return 'Paid';
      default:
        return type;
    }
  }

  BCBadgeVariant _collabTypeVariant(String type) {
    switch (type) {
      case 'barter':
        return BCBadgeVariant.neon;
      case 'paid':
        return BCBadgeVariant.outline;
      default:
        return BCBadgeVariant.outline;
    }
  }
}

class _BrandRequestDetailSheet extends StatelessWidget {
  const _BrandRequestDetailSheet({required this.request});

  final CollabRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: _avatarColor(request.brandInitial),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  request.brandInitial,
                  style: AppTypography.labelMD.copyWith(
                    color: AppColors.white, fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.brandName, style: AppTypography.labelLG.copyWith(fontWeight: FontWeight.w900)),
                    Text(
                      '${request.brandCategory} / ${timeago.format(request.receivedAt)}',
                      style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Deal Details', style: AppTypography.displaySM.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.md),
          _detailRow('Budget', Formatters.currency(request.budget)),
          const SizedBox(height: AppSpacing.sm),
          _detailRow('Type', _collabTypeLabel(request.collabType.name)),
          const SizedBox(height: AppSpacing.sm),
          _detailRow('Status', request.status),
          if (request.deliverables.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Deliverables', style: AppTypography.labelLG.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: request.deliverables.map((d) => BCBadge(
                label: d, variant: BCBadgeVariant.neon,
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySM.copyWith(color: AppColors.muted)),
        Text(value, style: AppTypography.labelMD.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Color _avatarColor(String initial) {
    final colors = [AppColors.pink, AppColors.purple, AppColors.orange, AppColors.skyBlue];
    final index = initial.isNotEmpty ? initial.codeUnitAt(0) % colors.length : 0;
    return colors[index];
  }

  String _collabTypeLabel(String type) {
    switch (type) {
      case ' barter': return 'Barter';
      case 'paid': return 'Paid';
      default: return type;
    }
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: filled ? AppColors.creatorDark : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: filled ? null : Border.all(color: AppColors.lightBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelMD.copyWith(
              color: filled ? AppColors.white : AppColors.creatorDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _AgencyPitchesTab extends ConsumerWidget {
  const _AgencyPitchesTab({required this.pitchesAsync});

  final AsyncValue<List<Map<String, dynamic>>> pitchesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return pitchesAsync.when(
      loading: () => const Center(child: BCAppLoader()),
      error: (error, _) => BCErrorState(
        message: error.toString(),
        onRetry: () => ref.read(creatorAgencyPitchesProvider.notifier).refresh(),
      ),
      data: (pitches) {
        if (pitches.isEmpty) {
          return const Center(
            child: BCEmptyState(
              emoji: '🏢',
              message: 'No agency pitches yet.',
            ),
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.md,
            AppSpacing.screenPadding,
            AppSpacing.huge,
          ),
          itemCount: pitches.length,
          itemBuilder: (context, index) {
            final pitch = pitches[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == pitches.length - 1 ? 0 : AppSpacing.md,
              ),
              child: _AgencyPitchCard(pitch: pitch),
            );
          },
        );
      },
    );
  }
}

class _AgencyPitchCard extends ConsumerWidget {
  const _AgencyPitchCard({required this.pitch});

  final Map<String, dynamic> pitch;

  void _viewAgencyProfile(BuildContext context) {
    final agency = pitch['agency'] ?? {};
    final agencyProfile = pitch['agency_profile'] ?? {};
    final agencyName = agency['agency_name'] ?? agencyProfile['first_name'] ?? agencyProfile['full_name'] ?? 'Agency';
    final agencyAvatar = agency['logo_url'] ?? agencyProfile['avatar_url'];
    final agencyId = _readString(agency['id']);
    final agencyProfileId = _readString(agencyProfile['id']);
    final resolvedId = agencyId.isNotEmpty ? agencyId : agencyProfileId;

    context.push(
      RouteNames.partnerProfile,
      extra: {
        'id': resolvedId,
        'role': 'brand',
        'full_name': agencyName,
        'name': agencyName,
        'avatar_url': agencyAvatar ?? '',
        if (pitch['pitch_message'] != null) 'bio': pitch['pitch_message'],
      },
    );
  }

  void _showPitchDetail(BuildContext context, WidgetRef ref) {
    final agency = pitch['agency'] ?? {};
    final agencyProfile = pitch['agency_profile'] ?? {};
    final agencyName = agency['agency_name'] ?? agencyProfile['first_name'] ?? agencyProfile['full_name'] ?? 'Agency';
    final agencyAvatar = agency['logo_url'] ?? agencyProfile['avatar_url'];
    final title = pitch['pitch_title'] ?? 'Pitch';
    final message = pitch['pitch_message'] ?? '';
    final status = pitch['status'] ?? 'pending';
    final monthlyFee = pitch['monthly_fee'];
    final profitRatio = pitch['profit_ratio'];
    final createdAt = pitch['created_at'];
    final isPending = status == 'pending';
    final agencyId = _readString(agency['id']);
    final agencyProfileId = _readString(agencyProfile['id']);
    final resolvedId = agencyId.isNotEmpty ? agencyId : agencyProfileId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AgencyPitchDetailSheet(
        pitchId: pitch['id'] ?? '',
        agencyName: agencyName,
        agencyAvatar: agencyAvatar,
        title: title,
        message: message,
        status: status,
        monthlyFee: monthlyFee,
        profitRatio: profitRatio,
        createdAt: createdAt,
        isPending: isPending,
        agencyId: resolvedId,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agency = pitch['agency'] ?? {};
    final agencyProfile = pitch['agency_profile'] ?? {};
    final agencyName = agency['agency_name'] ?? agencyProfile['first_name'] ?? agencyProfile['full_name'] ?? 'Agency';
    final agencyAvatar = agency['logo_url'] ?? agencyProfile['avatar_url'];
    final title = pitch['pitch_title'] ?? 'Pitch';
    final message = pitch['pitch_message'] ?? '';
    final status = pitch['status'] ?? 'pending';
    final monthlyFee = pitch['monthly_fee'];
    final profitRatio = pitch['profit_ratio'];
    final createdAt = pitch['created_at'];

    final statusColor = status == 'pending' 
        ? AppColors.warning 
        : status == 'accepted' 
            ? AppColors.success 
            : AppColors.gray;

    return GestureDetector(
      onTap: () => _showPitchDetail(context, ref),
      child: _CreatorCardShell(
        accent: AppColors.creatorPrimary,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.creatorDark.withValues(alpha: 0.15),
                  backgroundImage: agencyAvatar != null ? NetworkImage(agencyAvatar) : null,
                  child: agencyAvatar == null 
                      ? const Icon(Icons.business, color: AppColors.creatorDark, size: 16) 
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agencyName,
                        style: AppTypography.labelLG.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        createdAt != null ? timeago.format(DateTime.parse(createdAt)) : '',
                        style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toString().toUpperCase(),
                    style: AppTypography.labelXS.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.labelLG.copyWith(fontWeight: FontWeight.w900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                message,
                style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (monthlyFee != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.creatorPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '₹$monthlyFee/mo',
                      style: AppTypography.labelXS.copyWith(
                        color: AppColors.creatorDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                if (profitRatio != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.creatorPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$profitRatio%',
                      style: AppTypography.labelXS.copyWith(
                        color: AppColors.creatorDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _CardActionButton(
                    label: 'View Details',
                    filled: false,
                    onTap: () => _showPitchDetail(context, ref),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _CardActionButton(
                    label: 'View Profile',
                    filled: false,
                    onTap: () => _viewAgencyProfile(context),
                  ),
                ),
              ],
            ),
            if (status == 'pending') ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _CardActionButton(
                      label: 'Accept',
                      filled: true,
                      onTap: () {
                        _showPitchDetail(context, ref);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AgencyPitchDetailSheet extends ConsumerWidget {
  const _AgencyPitchDetailSheet({
    required this.pitchId,
    required this.agencyName,
    this.agencyAvatar,
    required this.title,
    required this.message,
    required this.status,
    this.monthlyFee,
    this.profitRatio,
    this.createdAt,
    required this.isPending,
    this.agencyId,
  });

  final String pitchId;
  final String agencyName;
  final String? agencyAvatar;
  final String title;
  final String message;
  final String status;
  final int? monthlyFee;
  final int? profitRatio;
  final String? createdAt;
  final bool isPending;
  final String? agencyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionLoading = ref.watch(creatorActionsProvider).isLoading;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.creatorDark.withValues(alpha: 0.15),
                backgroundImage: agencyAvatar != null ? NetworkImage(agencyAvatar!) : null,
                child: agencyAvatar == null
                    ? const Icon(Icons.business, color: AppColors.creatorDark, size: 22)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agencyName, style: AppTypography.labelLG.copyWith(fontWeight: FontWeight.w900)),
                    if (createdAt != null)
                      Text(
                        timeago.format(DateTime.parse(createdAt!)),
                        style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (status == 'pending' ? AppColors.warning : AppColors.success).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTypography.labelXS.copyWith(
                    color: status == 'pending' ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTypography.displaySM.copyWith(fontWeight: FontWeight.w900)),
          if (message.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: AppTypography.bodySM.copyWith(color: AppColors.muted)),
          ],
          if (monthlyFee != null || profitRatio != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (monthlyFee != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.creatorPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '₹$monthlyFee/mo',
                      style: AppTypography.labelXS.copyWith(
                        color: AppColors.creatorDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                if (profitRatio != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.creatorPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$profitRatio%',
                      style: AppTypography.labelXS.copyWith(
                        color: AppColors.creatorDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _CardActionButton(
                  label: 'View Agency Profile',
                  filled: false,
                  onTap: () {
                    final resolvedId = (agencyId ?? '').isNotEmpty ? agencyId! : '';
                    context.push(
                      RouteNames.partnerProfile,
                      extra: {
                        'id': resolvedId,
                        'role': 'brand',
                        'full_name': agencyName,
                        'name': agencyName,
                        'avatar_url': agencyAvatar ?? '',
                        if (message.isNotEmpty) 'bio': message,
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _CardActionButton(
                    label: 'Decline',
                    filled: false,
                    onTap: actionLoading
                        ? null
                        : () async {
                            try {
                              await ref
                                  .read(creatorActionsProvider.notifier)
                                  .respondToAgencyPitch(pitchId: pitchId, action: 'decline');
                              await ref.read(creatorAgencyPitchesProvider.notifier).refresh();
                              if (context.mounted) Navigator.of(context).pop();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _CardActionButton(
                    label: actionLoading ? 'Please wait...' : 'Accept',
                    filled: true,
                    onTap: actionLoading
                        ? null
                        : () async {
                            try {
                              await ref
                                  .read(creatorActionsProvider.notifier)
                                  .respondToAgencyPitch(pitchId: pitchId, action: 'accept');
                              await ref.read(creatorAgencyPitchesProvider.notifier).refresh();
                              if (context.mounted) Navigator.of(context).pop();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}