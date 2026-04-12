import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/india_locations.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_portal_top_bar.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/inputs/bc_dropdown.dart';
import '../../../widgets/inputs/bc_text_field.dart';
import '../widgets/campaign_card.dart';

enum _CampaignSort { newest, budgetAsc, budgetDesc }

class CampaignsScreen extends ConsumerStatefulWidget {
  const CampaignsScreen({super.key});

  @override
  ConsumerState<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends ConsumerState<CampaignsScreen> {
  final ScrollController _scrollController = ScrollController();

  String _activeChip = _campaignFilterChips.first;
  _CampaignSort _activeSort = _CampaignSort.newest;

  final Set<CampaignCollabType> _sheetCollabTypes = <CampaignCollabType>{};
  final Set<String> _sheetNiches = <String>{};
  int? _minBudgetInr;
  int? _maxBudgetInr;
  String? _filterState;
  String? _filterCity;
  bool _includePanIndia = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future<void>.microtask(() {
      ref.read(creatorHomeProvider);
      ref.read(myBidsProvider);
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    return ref.read(creatorCampaignsProvider.notifier).refresh();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (current >= max - 220) {
      ref.read(creatorCampaignsProvider.notifier).loadMore();
    }
  }

  Future<void> _applyServerFilters() {
    final chipCollabType = _chipCollabType(_activeChip);
    final chipNiche = _chipNiche(_activeChip);

    final filter = CreatorCampaignFilters(
      collabType: chipCollabType ??
          (_sheetCollabTypes.length == 1 ? _sheetCollabTypes.first : null),
      niche:
          chipNiche ?? (_sheetNiches.length == 1 ? _sheetNiches.first : null),
      minBudget: _minBudgetInr,
      maxBudget: _maxBudgetInr,
      state: _filterState,
      city: _filterCity,
      includePanIndia: _includePanIndia,
    );

    return ref.read(creatorCampaignsProvider.notifier).applyFilters(filter);
  }

  void _openFiltersSheet() {
    final minController = TextEditingController(
      text: _minBudgetInr?.toString() ?? '',
    );
    final maxController = TextEditingController(
      text: _maxBudgetInr?.toString() ?? '',
    );

    final workingCollabTypes = Set<CampaignCollabType>.from(_sheetCollabTypes);
    final workingNiches = Set<String>.from(_sheetNiches);
    String? workingState = _filterState;
    String? workingCity = _filterCity;
    bool workingIncludePanIndia = _includePanIndia;

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
                                label: 'Min (INR)',
                                hint: '1000',
                                keyboardType: TextInputType.number,
                                controller: minController,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: BCTextField(
                                label: 'Max (INR)',
                                hint: '10000',
                                keyboardType: TextInputType.number,
                                controller: maxController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Divider(color: AppColors.divider),
                        const SizedBox(height: AppSpacing.md),
                        const Text('Location', style: AppTypography.labelMD),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: BCDropdown(
                                label: 'State',
                                value: workingState,
                                hint: 'All India',
                                items: const ['All India', ...IndiaLocations.states],
                                onChanged: (value) {
                                  setSheetState(() {
                                    workingState = value == 'All India' ? null : value;
                                    workingCity = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: BCDropdown(
                                label: 'City',
                                value: workingCity,
                                hint: workingState == null ? 'All Cities' : 'Select city',
                                items: workingState == null
                                    ? const ['All Cities']
                                    : ['All Cities', ...IndiaLocations.getCities(workingState!)],
                                onChanged: workingState == null
                                    ? null
                                    : (value) {
                                        setSheetState(() {
                                          workingCity = value == 'All Cities' ? null : value;
                                        });
                                      },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Checkbox(
                              value: workingIncludePanIndia,
                              onChanged: (value) {
                                setSheetState(() {
                                  workingIncludePanIndia = value ?? true;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text('Include Pan India campaigns'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
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
                          onPressed: () async {
                            setState(() {
                              _sheetCollabTypes
                                ..clear()
                                ..addAll(workingCollabTypes);
                              _sheetNiches
                                ..clear()
                                ..addAll(workingNiches);
                              _minBudgetInr =
                                  int.tryParse(minController.text.trim());
                              _maxBudgetInr =
                                  int.tryParse(maxController.text.trim());
                                _filterState = workingState;
                                _filterCity = workingCity;
                                _includePanIndia = workingIncludePanIndia;
                            });
                            Navigator.of(context).pop();
                            await _applyServerFilters();
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () async {
                              setState(() {
                                _sheetCollabTypes.clear();
                                _sheetNiches.clear();
                                _minBudgetInr = null;
                                _maxBudgetInr = null;
                                _filterState = null;
                                _filterCity = null;
                                _includePanIndia = true;
                              });
                              Navigator.of(context).pop();
                              await _applyServerFilters();
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

  List<Campaign> _applyLocalFilters(List<Campaign> campaigns) {
    final filtered = campaigns.where((campaign) {
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

      final minBudgetPaise =
          _minBudgetInr == null ? null : _minBudgetInr! * 100;
      final maxBudgetPaise =
          _maxBudgetInr == null ? null : _maxBudgetInr! * 100;

      if (minBudgetPaise != null && campaign.maxBudget < minBudgetPaise) {
        return false;
      }

      if (maxBudgetPaise != null && campaign.minBudget > maxBudgetPaise) {
        return false;
      }

      return true;
    }).toList();

    switch (_activeSort) {
      case _CampaignSort.newest:
        filtered.sort((a, b) => b.deadline.compareTo(a.deadline));
      case _CampaignSort.budgetAsc:
        filtered.sort((a, b) => a.minBudget.compareTo(b.minBudget));
      case _CampaignSort.budgetDesc:
        filtered.sort((a, b) => b.maxBudget.compareTo(a.maxBudget));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(creatorCampaignsProvider);

    return Scaffold(
      extendBody: true,
      appBar: const BCPortalTopBar(),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 1,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: FloatingActionButton(
          heroTag: 'creatorCampaignFiltersFab',
          onPressed: _openFiltersSheet,
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.neon,
          tooltip: 'Filter campaigns',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            side: const BorderSide(color: AppColors.neon, width: 2),
          ),
          child: const Icon(Symbols.tune_rounded),
        ),
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.creator,
        currentIndex: 1,
        child: RefreshIndicator(
          color: AppColors.neon,
          onRefresh: _refresh,
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.huge,
            ),
            children: [
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _campaignFilterChips.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final chip = _campaignFilterChips[index];
                    final isActive = chip == _activeChip;
                    return _NeoPill(
                      label: chip,
                      isActive: isActive,
                      onTap: () async {
                        setState(() {
                          _activeChip = chip;
                        });
                        await _applyServerFilters();
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
                    onTap: () =>
                        setState(() => _activeSort = _CampaignSort.newest),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _SortPill(
                    label: 'Budget ↑',
                    isActive: _activeSort == _CampaignSort.budgetAsc,
                    onTap: () =>
                        setState(() => _activeSort = _CampaignSort.budgetAsc),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _SortPill(
                    label: 'Budget ↓',
                    isActive: _activeSort == _CampaignSort.budgetDesc,
                    onTap: () =>
                        setState(() => _activeSort = _CampaignSort.budgetDesc),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              campaignsAsync.when(
                loading: () => Column(
                  children: List.generate(
                    4,
                    (index) => const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: SizedBox(
                        height: 220,
                        child: CampaignCardSkeleton(width: double.infinity),
                      ),
                    ),
                  ),
                ),
                error: (error, _) => BCErrorState(
                  message: error.toString(),
                  onRetry: _refresh,
                ),
                data: (state) {
                  final visibleCampaigns = _applyLocalFilters(state.campaigns);
                  if (visibleCampaigns.isEmpty) {
                    return const BCEmptyState(
                      emoji: '🔍',
                      message: 'No campaigns match your filters.',
                    );
                  }

                  return Column(
                    children: [
                      for (final campaign in visibleCampaigns)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: SizedBox(
                            height: 220,
                            child: CampaignCard(
                              width: double.infinity,
                              campaign: campaign,
                              onTap: () => context.push(
                                RouteNames.campaignDetail
                                    .replaceFirst(':id', campaign.id),
                              ),
                            ),
                          ),
                        ),
                      if (state.isLoadingMore)
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          child: Center(
                            child:
                                CircularProgressIndicator(color: AppColors.ink),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
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
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.ink : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.ink, width: 2),
          boxShadow: AppShadows.softTight(context),
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
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.ink : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.ink, width: 1.5),
          boxShadow: AppShadows.softTight(context),
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

CampaignCollabType? _chipCollabType(String chip) {
  switch (chip) {
    case 'Paid':
      return CampaignCollabType.paid;
    case 'Barter':
      return CampaignCollabType.barter;
    case 'Hybrid':
      return CampaignCollabType.hybrid;
    default:
      return null;
  }
}

String? _chipNiche(String chip) {
  if (_nicheFilters.contains(chip)) {
    return chip;
  }
  return null;
}
