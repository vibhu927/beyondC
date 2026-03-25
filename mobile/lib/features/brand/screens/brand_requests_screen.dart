import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';

class BrandRequestsScreen extends ConsumerStatefulWidget {
  const BrandRequestsScreen({super.key});

  @override
  ConsumerState<BrandRequestsScreen> createState() =>
      _BrandRequestsScreenState();
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
      await ref.read(brandRequestsProvider.notifier).refresh();
      _resyncVisibleList(
          ref.read(brandRequestsProvider).valueOrNull ?? const []);
    });

    ref.listenManual<AsyncValue<List<CollabRequest>>>(
      brandRequestsProvider,
      (_, next) {
        _resyncVisibleList(next.valueOrNull ?? const []);
      },
    );
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
          return (b.createdAt ?? DateTime(1970))
              .compareTo(a.createdAt ?? DateTime(1970));
        case _RequestSort.oldest:
          return (a.createdAt ?? DateTime(1970))
              .compareTo(b.createdAt ?? DateTime(1970));
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
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
                  const Text('Filters', style: AppTypography.displaySM),
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
                        onTap: () {
                          setSheetState(() {
                            if (active) {
                              workingTypes.remove(type);
                            } else {
                              workingTypes.add(type);
                            }
                          });
                        },
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
                    label: 'Apply →',
                    onPressed: () {
                      setState(() {
                        _types
                          ..clear()
                          ..addAll(workingTypes);
                        _sort = workingSort;
                        _listKey = GlobalKey<AnimatedListState>();
                        _visibleRequests = _applyFilters(
                          ref.read(brandRequestsProvider).valueOrNull ??
                              const [],
                        );
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Request?'),
          content: const Text('This will remove your pending request.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final index = _visibleRequests.indexWhere((item) => item.id == request.id);
    if (index == -1) return;

    final removed = _visibleRequests[index];
    setState(() {
      _visibleRequests.removeAt(index);
    });

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: _RequestCard(
          request: removed,
          onCancel: () {},
        ),
      ),
      duration: const Duration(milliseconds: 280),
    );

    try {
      await ref.read(brandRequestsProvider.notifier).cancelRequest(request.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request cancelled.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _visibleRequests.insert(index, removed);
      });
      _listKey.currentState?.insertItem(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not cancel request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(brandRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests 📩', style: AppTypography.displaySM),
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: const Icon(Icons.tune_rounded, color: AppColors.ink),
          ),
        ],
      ),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.brand,
        currentIndex: 2,
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          _TabBarPills(
            activeTab: _activeTab,
            onChanged: (tab) {
              setState(() {
                _activeTab = tab;
                _listKey = GlobalKey<AnimatedListState>();
                _visibleRequests = _applyFilters(
                  requestsAsync.valueOrNull ?? const [],
                );
              });
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: requestsAsync.when(
              loading: () => const _RequestListShimmer(),
              error: (error, _) => BCErrorState(
                message: error.toString(),
                onRetry: () =>
                    ref.read(brandRequestsProvider.notifier).refresh(),
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
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onCancel,
  });

  final CollabRequest request;
  final VoidCallback onCancel;

  bool get _isAccepted => request.status.toLowerCase() == 'accepted';
  bool get _isPending => request.status.toLowerCase() == 'pending';
  bool get _isRejectedOrExpired {
    final status = request.status.toLowerCase();
    return status == 'rejected' || status == 'expired';
  }

  @override
  Widget build(BuildContext context) {
    final shadow = _isPending
        ? AppShadows.neon
        : _isAccepted
            ? AppShadows.blue
            : const <BoxShadow>[];

    return BCCard(
      shadow: shadow,
      borderColor: _isRejectedOrExpired ? AppColors.darkBorder : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.ink, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initial(request.creatorFirstName ?? 'C'),
                  style: AppTypography.labelMD.copyWith(color: AppColors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.creatorFirstName ?? 'Creator',
                      style: AppTypography.labelLG,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    BCBadge(
                      label: request.creatorTier ?? 'micro',
                      variant: BCBadgeVariant.outline,
                    ),
                  ],
                ),
              ),
              BCBadge(
                label: _statusLabel(request.status),
                variant: _statusVariant(request.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                Formatters.currencyFromINR(request.budget ?? 0),
                style: AppTypography.displaySM,
              ),
              const SizedBox(width: AppSpacing.sm),
              BCBadge(
                label: _collabTypeLabel(request.collabType),
                variant: _collabTypeVariant(request.collabType),
              ),
            ],
          ),
          if (request.deliverables.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              request.deliverables.join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySM.copyWith(color: AppColors.muted),
            ),
          ],
          if ((request.message ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '"${request.message!.trim()}"',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySM.copyWith(
                color: AppColors.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            timeago.format(request.createdAt ?? DateTime.now()),
            style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
          ),
          if (_isAccepted) ...[
            const SizedBox(height: AppSpacing.md),
            BCCard(
              shadow: AppShadows.neon,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BCBadge(
                          label: '🔓 Unlocked',
                          variant: BCBadgeVariant.neon,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          request.creatorFullName ??
                              request.creatorFirstName ??
                              'Creator',
                          style: AppTypography.labelMD,
                        ),
                        if ((request.creatorInstagramHandle ?? '')
                            .trim()
                            .isNotEmpty)
                          Text(
                            '@${request.creatorInstagramHandle}',
                            style: AppTypography.labelSM
                                .copyWith(color: AppColors.purple),
                          ),
                      ],
                    ),
                  ),
                  if ((request.collabId ?? '').isNotEmpty)
                    BCPrimaryButton.dark(
                      label: 'Open Chat →',
                      isFullWidth: false,
                      onPressed: () => context.push(
                        RouteNames.brandChat
                            .replaceFirst(':id', request.collabId!),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (_isPending) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.6),
                ),
                child: const Text('Cancel Request'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabBarPills extends StatelessWidget {
  const _TabBarPills({
    required this.activeTab,
    required this.onChanged,
  });

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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.ink : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.ink, width: 2),
                ),
                child: Text(
                  _BrandRequestsScreenState._tabLabels[tab]!,
                  style: AppTypography.labelSM.copyWith(
                    color: isActive ? AppColors.neon : AppColors.ink,
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
  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: active ? AppColors.neon : AppColors.ink,
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
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 172,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(color: AppColors.ink, width: 2),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemCount: 5,
    );
  }
}

String _initial(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 'C';
  return trimmed.substring(0, 1).toUpperCase();
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 'Pending';
    case 'accepted':
      return '✅ Accepted';
    case 'rejected':
      return 'Rejected';
    case 'expired':
      return 'Expired';
    default:
      return status;
  }
}

BCBadgeVariant _statusVariant(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return BCBadgeVariant.warning;
    case 'accepted':
      return BCBadgeVariant.success;
    case 'rejected':
      return BCBadgeVariant.error;
    case 'expired':
      return BCBadgeVariant.outline;
    default:
      return BCBadgeVariant.outline;
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
      return 'Budget ↑';
    case _RequestSort.budgetDesc:
      return 'Budget ↓';
  }
}

String _emptyMessage(_RequestTab tab) {
  switch (tab) {
    case _RequestTab.active:
      return 'No active requests.\nSend a request from Creator Discovery.';
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
