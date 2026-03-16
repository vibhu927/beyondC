import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/campaign_provider.dart';
import '../../../widgets/bc_app_bar.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/inputs/bc_text_field.dart';
import '../widgets/campaign_card.dart';

enum _CampaignSort { newest, budgetAsc, budgetDesc }

class CampaignsScreen extends ConsumerStatefulWidget {
  const CampaignsScreen({super.key});

  @override
  ConsumerState<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends ConsumerState<CampaignsScreen> {
  static const _pageSize = 6;

  final ScrollController _scrollController = ScrollController();

  String _activeChip = _campaignFilterChips.first;
  _CampaignSort _activeSort = _CampaignSort.newest;

  final Set<CampaignCollabType> _sheetCollabTypes = <CampaignCollabType>{};
  final Set<String> _sheetNiches = <String>{};
  int? _minBudget;
  int? _maxBudget;

  int _visibleCount = _pageSize;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future<void>.microtask(
      () => ref.read(campaignProvider.notifier).fetchCampaigns(),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(campaignProvider.notifier).refreshCampaigns();
    if (mounted) {
      setState(() {
        _visibleCount = _pageSize;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (current >= max - 220) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final campaigns = _applySort(_applyFilters(ref.read(campaignProvider).campaigns));
    if (_visibleCount >= campaigns.length) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;
    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, campaigns.length);
      _isLoadingMore = false;
    });
  }

  void _openFiltersSheet() {
    final minController = TextEditingController(
      text: _minBudget?.toString() ?? '',
    );
    final maxController = TextEditingController(
      text: _maxBudget?.toString() ?? '',
    );

    final workingCollabTypes = Set<CampaignCollabType>.from(_sheetCollabTypes);
    final workingNiches = Set<String>.from(_sheetNiches);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(color: AppColors.ink, width: 2),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filter Campaigns',
                          style: AppTypography.displaySM,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'Collab Type',
                          style: AppTypography.labelMD,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: CampaignCollabType.values.map((type) {
                            final isActive = workingCollabTypes.contains(type);
                            return _NeoPill(
                              label: _collabTypeLabel(type),
                              isActive: isActive,
                              onTap: () {
                                setSheetState(() {
                                  if (isActive) {
                                    workingCollabTypes.remove(type);
                                  } else {
                                    workingCollabTypes.add(type);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: BCTextField(
                                label: 'Min ₹',
                                hint: '1000',
                                keyboardType: TextInputType.number,
                                controller: minController,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: BCTextField(
                                label: 'Max ₹',
                                hint: '10000',
                                keyboardType: TextInputType.number,
                                controller: maxController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text('Niche', style: AppTypography.labelMD),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: _nicheFilters.map((niche) {
                            final isActive = workingNiches.contains(niche);
                            return _NeoPill(
                              label: niche,
                              isActive: isActive,
                              onTap: () {
                                setSheetState(() {
                                  if (isActive) {
                                    workingNiches.remove(niche);
                                  } else {
                                    workingNiches.add(niche);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        BCPrimaryButton.neon(
                          label: 'Apply Filters →',
                          onPressed: () {
                            setState(() {
                              _sheetCollabTypes
                                ..clear()
                                ..addAll(workingCollabTypes);
                              _sheetNiches
                                ..clear()
                                ..addAll(workingNiches);
                              _minBudget = int.tryParse(minController.text.trim());
                              _maxBudget = int.tryParse(maxController.text.trim());
                              _visibleCount = _pageSize;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _sheetCollabTypes.clear();
                                _sheetNiches.clear();
                                _minBudget = null;
                                _maxBudget = null;
                                _visibleCount = _pageSize;
                              });
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.pink,
                            ),
                            child: const Text('Clear All'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      minController.dispose();
      maxController.dispose();
    });
  }

  List<Campaign> _applyFilters(List<Campaign> campaigns) {
    return campaigns.where((campaign) {
      final chipMatch = switch (_activeChip) {
        'All' => true,
        'Paid' => campaign.collabType == CampaignCollabType.paid,
        'Barter' => campaign.collabType == CampaignCollabType.barter,
        'Hybrid' => campaign.collabType == CampaignCollabType.hybrid,
        _ => campaign.brandCategory.toLowerCase() == _activeChip.toLowerCase(),
      };

      if (!chipMatch) return false;

      if (_sheetCollabTypes.isNotEmpty &&
          !_sheetCollabTypes.contains(campaign.collabType)) {
        return false;
      }

      if (_sheetNiches.isNotEmpty &&
          !_sheetNiches
              .map((e) => e.toLowerCase())
              .contains(campaign.brandCategory.toLowerCase())) {
        return false;
      }

      if (_minBudget != null && campaign.maxBudget < _minBudget!) {
        return false;
      }

      if (_maxBudget != null && campaign.minBudget > _maxBudget!) {
        return false;
      }

      return true;
    }).toList();
  }

  List<Campaign> _applySort(List<Campaign> campaigns) {
    final sorted = [...campaigns];
    switch (_activeSort) {
      case _CampaignSort.newest:
        sorted.sort((a, b) => b.deadline.compareTo(a.deadline));
      case _CampaignSort.budgetAsc:
        sorted.sort((a, b) => a.minBudget.compareTo(b.minBudget));
      case _CampaignSort.budgetDesc:
        sorted.sort((a, b) => b.maxBudget.compareTo(a.maxBudget));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final campaignState = ref.watch(campaignProvider);
    final filteredCampaigns = _applySort(_applyFilters(campaignState.campaigns));
    final visibleCampaigns = filteredCampaigns.take(_visibleCount).toList();

    return Scaffold(
      appBar: BCAppBar(
        title: 'Campaigns',
        actions: [
          IconButton(
            onPressed: _openFiltersSheet,
            icon: const Icon(Icons.tune_rounded, color: AppColors.ink),
            tooltip: 'Filter campaigns',
          ),
        ],
      ),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 1,
      ),
      body: RefreshIndicator(
        color: AppColors.neon,
        onRefresh: _refresh,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.lg,
            AppSpacing.screenPadding,
            AppSpacing.huge,
          ),
          children: [
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _campaignFilterChips.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final chip = _campaignFilterChips[index];
                  final isActive = chip == _activeChip;
                  return _NeoPill(
                    label: chip,
                    isActive: isActive,
                    onTap: () {
                      setState(() {
                        _activeChip = chip;
                        _visibleCount = _pageSize;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Text('Sort by:', style: AppTypography.labelMD),
                const SizedBox(width: AppSpacing.sm),
                _SortPill(
                  label: 'Newest',
                  isActive: _activeSort == _CampaignSort.newest,
                  onTap: () {
                    setState(() {
                      _activeSort = _CampaignSort.newest;
                      _visibleCount = _pageSize;
                    });
                  },
                ),
                const SizedBox(width: AppSpacing.xs),
                _SortPill(
                  label: 'Budget ↑',
                  isActive: _activeSort == _CampaignSort.budgetAsc,
                  onTap: () {
                    setState(() {
                      _activeSort = _CampaignSort.budgetAsc;
                      _visibleCount = _pageSize;
                    });
                  },
                ),
                const SizedBox(width: AppSpacing.xs),
                _SortPill(
                  label: 'Budget ↓',
                  isActive: _activeSort == _CampaignSort.budgetDesc,
                  onTap: () {
                    setState(() {
                      _activeSort = _CampaignSort.budgetDesc;
                      _visibleCount = _pageSize;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (campaignState.isLoading)
              Column(
                children: List.generate(
                  4,
                  (index) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: SizedBox(
                      height: 220,
                      child: CampaignCardSkeleton(),
                    ),
                  ),
                ),
              )
            else if (visibleCampaigns.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
                child: Text(
                  '🔍 No campaigns match your filters.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
                ),
              )
            else
              Column(
                children: [
                  for (final campaign in visibleCampaigns)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: SizedBox(
                        height: 220,
                        child: CampaignCard(
                          campaign: campaign,
                          onTap: () => context.push(
                            RouteNames.campaignDetail
                                .replaceFirst(':id', campaign.id),
                          ),
                        ),
                      ),
                    ),
                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.ink),
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

class _NeoPill extends StatelessWidget {
  const _NeoPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
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
          color: isActive ? AppColors.ink : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: isActive ? AppColors.neon : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _SortPill extends StatelessWidget {
  const _SortPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
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
          color: isActive ? AppColors.ink : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.ink, width: 1.5),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: isActive ? AppColors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

const _campaignFilterChips = [
  'All',
  'Paid',
  'Barter',
  'Hybrid',
  'Fashion',
  'Fitness',
  'Food',
  'Tech',
  'Beauty',
];

const _nicheFilters = ['Fashion', 'Fitness', 'Food', 'Tech', 'Beauty'];

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
