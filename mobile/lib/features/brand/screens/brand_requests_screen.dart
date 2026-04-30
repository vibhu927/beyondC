import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/brand_page_top_header.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../chat/chat_screen.dart';

class BrandRequestsScreen extends ConsumerStatefulWidget {
  const BrandRequestsScreen({super.key});

  @override
  ConsumerState<BrandRequestsScreen> createState() => _BrandRequestsScreenState();
}

enum _RequestTab { active, accepted, rejectedExpired }
enum _RequestSort { newest, oldest, budgetAsc, budgetDesc }

class _BrandRequestsScreenState extends ConsumerState<BrandRequestsScreen> {
  static const _tabLabels = {
    _RequestTab.active: 'Active',
    _RequestTab.accepted: 'Accepted',
    _RequestTab.rejectedExpired: 'Rejected/Expired',
  };

  _RequestTab _activeTab = _RequestTab.active;
  _RequestSort _sort = _RequestSort.newest;
  final Set<CampaignCollabType> _types = <CampaignCollabType>{};
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<CollabRequest> _visibleRequests = const <CollabRequest>[];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      final cached = ref.read(brandRequestsProvider).valueOrNull;
      if (cached == null) {
        await ref.read(brandRequestsProvider.notifier).refresh();
      }
      _resyncVisibleList(ref.read(brandRequestsProvider).valueOrNull ?? const []);
      ref.listenManual<AsyncValue<List<CollabRequest>>>(
        brandRequestsProvider,
        (_, next) => _resyncVisibleList(next.valueOrNull ?? const []),
      );
    });
  }

  List<CollabRequest> _applyFilters(List<CollabRequest> source) {
    final tabFiltered = source.where((request) {
      final status = request.status.toLowerCase();
      switch (_activeTab) {
        case _RequestTab.active:
          return status == 'pending';
        case _RequestTab.accepted:
          return status == 'accepted';
        case _RequestTab.rejectedExpired:
          return status == 'rejected' || status == 'expired';
      }
    });
    final typeFiltered = tabFiltered.where((request) {
      if (_types.isEmpty) return true;
      return _types.contains(request.collabType);
    }).toList();
    typeFiltered.sort((a, b) {
      switch (_sort) {
        case _RequestSort.newest:
          return (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970));
        case _RequestSort.oldest:
          return (a.createdAt ?? DateTime(1970)).compareTo(b.createdAt ?? DateTime(1970));
        case _RequestSort.budgetAsc:
          return (a.budget ?? 0).compareTo(b.budget ?? 0);
        case _RequestSort.budgetDesc:
          return (b.budget ?? 0).compareTo(a.budget ?? 0);
      }
    });
    return typeFiltered;
  }

  void _resyncVisibleList(List<CollabRequest> source) {
    if (!mounted) return;
    setState(() {
      _listKey = GlobalKey<AnimatedListState>();
      _visibleRequests = _applyFilters(source);
    });
  }

  Future<void> _openFilters() async {
    final workingTypes = Set<CampaignCollabType>.from(_types);
    var workingSort = _sort;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.lightBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.16)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.huge,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filters',
                      style: AppTypography.displaySM.copyWith(
                        color: AppColors.brandDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text('Collab Type', style: AppTypography.labelMD),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: CampaignCollabType.values.map((type) {
                        final active = workingTypes.contains(type);
                        return _FilterPill(
                          label: _collabTypeLabel(type),
                          active: active,
                          onTap: () => setSheetState(() {
                            active ? workingTypes.remove(type) : workingTypes.add(type);
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text('Sort', style: AppTypography.labelMD),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _RequestSort.values.map((sort) {
                        return _FilterPill(
                          label: _sortLabel(sort),
                          active: workingSort == sort,
                          onTap: () => setSheetState(() => workingSort = sort),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    BCPrimaryButton.neon(
                      label: 'Apply ->',
                      onPressed: () {
                        setState(() {
                          _types
                            ..clear()
                            ..addAll(workingTypes);
                          _sort = workingSort;
                          _listKey = GlobalKey<AnimatedListState>();
                          _visibleRequests = _applyFilters(
                            ref.read(brandRequestsProvider).valueOrNull ?? const [],
                          );
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _cancelRequest(CollabRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: BCCard(
            shadow: AppShadows.ink,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cancel Request?', style: AppTypography.displaySM),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This will remove your pending request.',
                  style: AppTypography.bodySM.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: BCPrimaryButton.pink(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: BCPrimaryButton.dark(
                        label: 'Keep',
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true) return;

    final index = _visibleRequests.indexWhere((item) => item.id == request.id);
    if (index == -1) return;
    final removed = _visibleRequests[index];
    setState(() => _visibleRequests.removeAt(index));
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: _RequestCard(request: removed, onCancel: () {}),
      ),
      duration: const Duration(milliseconds: 280),
    );
    try {
      await ref.read(brandRequestsProvider.notifier).cancelRequest(request.id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _visibleRequests.insert(index, removed));
      _listKey.currentState?.insertItem(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(brandRequestsProvider);
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const BCBottomNav(role: BCPortalRole.brand, currentIndex: 2),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: FloatingActionButton(
          heroTag: 'brandRequestsFiltersFab',
          onPressed: _openFilters,
          backgroundColor: AppColors.brandDark,
          foregroundColor: AppColors.brandPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            side: BorderSide(color: AppColors.brandDark.withValues(alpha: 0.2), width: 1.5),
          ),
          child: const Icon(Icons.tune_rounded),
        ),
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.brand,
        currentIndex: 2,
        child: Stack(
          children: [
            const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(color: AppColors.lightBg))),
            Positioned(
              top: -46,
              right: -32,
              child: _GlowOrb(size: 136, color: AppColors.brandPrimary.withValues(alpha: 0.08)),
            ),
            Positioned(
              top: 220,
              left: -44,
              child: _GlowOrb(size: 112, color: AppColors.brandDark.withValues(alpha: 0.08)),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    MediaQuery.of(context).padding.top + 14,
                    AppSpacing.screenPadding,
                    AppSpacing.sm,
                  ),
                  child: const BrandPageTopHeader(),
                ),
                const SizedBox(height: AppSpacing.sm),
                _TabBarPills(
                  activeTab: _activeTab,
                  onChanged: (tab) {
                    setState(() {
                      _activeTab = tab;
                      _listKey = GlobalKey<AnimatedListState>();
                      _visibleRequests = _applyFilters(requestsAsync.valueOrNull ?? const []);
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: requestsAsync.when(
                    loading: () => const _RequestListShimmer(),
                    error: (error, _) => BCErrorState(
                      message: error.toString(),
                      onRetry: () => ref.read(brandRequestsProvider.notifier).refresh(),
                    ),
                    data: (_) {
                      if (_visibleRequests.isEmpty) {
                        return BCEmptyState(
                          emoji: _emptyEmoji(_activeTab),
                          message: _emptyMessage(_activeTab),
                        );
                      }
                      return AnimatedList(
                        key: _listKey,
                        initialItemCount: _visibleRequests.length,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenPadding,
                          AppSpacing.sm,
                          AppSpacing.screenPadding,
                          AppSpacing.huge,
                        ),
                        itemBuilder: (context, index, animation) {
                          final request = _visibleRequests[index];
                          return SizeTransition(
                            sizeFactor: animation,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _RequestCard(
                                request: request,
                                onCancel: () => _cancelRequest(request),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onCancel});
  final CollabRequest request;
  final VoidCallback onCancel;

  bool get _isAccepted => request.status.toLowerCase() == 'accepted';
  bool get _isPending => request.status.toLowerCase() == 'pending';

  @override
  Widget build(BuildContext context) {
    final creatorName = request.creatorFirstName ?? 'Creator';
    final avatarLabel = creatorName.trim().isEmpty
        ? 'C'
        : creatorName.trim().substring(0, 1).toUpperCase();
    final deliverables = request.deliverables.take(2).join(' / ');
    final createdAtLabel = timeago.format(request.createdAt ?? DateTime.now());

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.lightBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.brandDark.withValues(alpha: 0.14),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  avatarLabel,
                  style: AppTypography.labelMD.copyWith(
                    color: AppColors.brandDark,
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
                      creatorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLG.copyWith(
                        color: AppColors.brandDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      createdAtLabel,
                      style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            Formatters.currencyFromINR(request.budget ?? 0),
            style: AppTypography.displaySM.copyWith(
              color: AppColors.brandDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            deliverables.isEmpty
                ? 'Deliverables discussed after approval'
                : deliverables,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _RequestStatusPill(
                label: _statusLabel(request.status),
                isPrimary: _isPending,
              ),
              const SizedBox(width: AppSpacing.sm),
              BCBadge(
                label: _collabTypeLabel(request.collabType),
                variant: _collabTypeVariant(request.collabType),
              ),
            ],
          ),
          if (_isAccepted && (request.collabId ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: _BriefStyleActionButton(
                label: 'Open Chat',
                onPressed: () => openChatDrawer(context, request.collabId!),
              ),
            ),
          ],
          if (_isPending) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: _BriefStyleActionButton(
                label: 'Cancel Request',
                onPressed: onCancel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RequestStatusPill extends StatelessWidget {
  const _RequestStatusPill({required this.label, required this.isPrimary});

  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.brandPrimary : AppColors.brandDark.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: AppTypography.labelXS.copyWith(
          color: AppColors.brandDark,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BriefStyleActionButton extends StatelessWidget {
  const _BriefStyleActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.brandDark,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            label,
            style: AppTypography.labelSM.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarPills extends StatelessWidget {
  const _TabBarPills({required this.activeTab, required this.onChanged});
  final _RequestTab activeTab;
  final ValueChanged<_RequestTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: _RequestTab.values.map((tab) {
          final isActive = tab == activeTab;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => onChanged(tab),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.brandDark : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.2)),
                ),
                child: Text(
                  _BrandRequestsScreenState._tabLabels[tab]!,
                  style: AppTypography.labelSM.copyWith(
                    color: isActive ? AppColors.brandPrimary : AppColors.brandDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: active ? AppColors.brandDark : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: active ? AppColors.brandPrimary : AppColors.brandDark,
          ),
        ),
      ),
    );
  }
}

class _RequestListShimmer extends StatelessWidget {
  const _RequestListShimmer();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.huge,
      ),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 172,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
            border: Border.all(color: AppColors.lightBorder),
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: size * 0.55, spreadRadius: size * 0.04),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 'Pending';
    case 'accepted':
      return 'Accepted';
    case 'rejected':
      return 'Rejected';
    case 'expired':
      return 'Expired';
    default:
      return status;
  }
}

String _collabTypeLabel(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return 'Paid';
    case CampaignCollabType.barter:
      return 'Barter';
    case CampaignCollabType.hybrid:
      return 'Hybrid';
  }
}

BCBadgeVariant _collabTypeVariant(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return BCBadgeVariant.blue;
    case CampaignCollabType.barter:
      return BCBadgeVariant.purple;
    case CampaignCollabType.hybrid:
      return BCBadgeVariant.orange;
  }
}

String _sortLabel(_RequestSort sort) {
  switch (sort) {
    case _RequestSort.newest:
      return 'Newest';
    case _RequestSort.oldest:
      return 'Oldest';
    case _RequestSort.budgetAsc:
      return 'Budget Low';
    case _RequestSort.budgetDesc:
      return 'Budget High';
  }
}

String _emptyMessage(_RequestTab tab) {
  switch (tab) {
    case _RequestTab.active:
      return 'No active requests. Send a request from Creator Discovery.';
    case _RequestTab.accepted:
      return 'No accepted requests yet.';
    case _RequestTab.rejectedExpired:
      return 'No rejected or expired requests.';
  }
}

String _emptyEmoji(_RequestTab tab) {
  switch (tab) {
    case _RequestTab.active:
      return '📩';
    case _RequestTab.accepted:
      return '🤝';
    case _RequestTab.rejectedExpired:
      return '📭';
  }
}

