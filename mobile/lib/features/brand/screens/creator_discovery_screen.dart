import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/india_locations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/bc_glass_header_bar.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/inputs/bc_dropdown.dart';
import '../../../widgets/inputs/bc_text_field.dart';
import '../widgets/creator_card.dart';
import '../widgets/creator_detail_bottom_sheet.dart';

class CreatorDiscoveryScreen extends ConsumerStatefulWidget {
  const CreatorDiscoveryScreen({super.key});

  @override
  ConsumerState<CreatorDiscoveryScreen> createState() =>
      _CreatorDiscoveryScreenState();
}

class _CreatorDiscoveryScreenState
    extends ConsumerState<CreatorDiscoveryScreen> {
  final _searchController = TextEditingController();
  String _activeNiche = 'All';
  String? _filterState;
  String? _filterCity;

  final Set<String> _selectedTiers = <String>{};
  int? _maxBudget;
  String _platform = 'Both';
  double? _minEngagement;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(brandProvider.notifier).fetchBrandHome();
      final brand = ref.read(brandProvider).brandProfile;
      _filterState = brand?.state;
      _filterCity = brand?.city;
      if (!mounted) return;
      await ref
          .read(brandProvider.notifier)
          .fetchDiscovery(stateFilter: _filterState, cityFilter: _filterCity);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandState = ref.watch(brandProvider);
    final creators = _filteredCreators(brandState.creators);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: FloatingActionButton(
          heroTag: 'creatorDiscoveryFiltersFab',
          onPressed: _openFilterBottomSheet,
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.neon,
          tooltip: 'Filters',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            side: const BorderSide(color: AppColors.neon, width: 2),
          ),
          child: const Icon(Icons.tune_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            BCGlassHeaderBar(
              title: 'Find Creators',
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  AppSpacing.huge,
                ),
                children: [
                  BCTextField(
                    label: 'Search',
                    hint: 'Search by niche, name...',
                    controller: _searchController,
                    prefixIcon: const Icon(Symbols.search_rounded),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _niches.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final niche = _niches[index];
                        final active = _activeNiche == niche;
                        return _pill(
                          label: niche,
                          active: active,
                          onTap: () => setState(() => _activeNiche = niche),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: BCDropdown(
                          label: 'State',
                          value: _filterState,
                          hint: 'All India',
                          items: const ['All India', ...IndiaLocations.states],
                          onChanged: (value) async {
                            final normalized = value == 'All India' ? null : value;
                            setState(() {
                              _filterState = normalized;
                              _filterCity = null;
                            });
                            await ref.read(brandProvider.notifier).fetchDiscovery(
                                  stateFilter: _filterState,
                                  cityFilter: _filterCity,
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: BCDropdown(
                          label: 'City',
                          value: _filterCity,
                          hint: _filterState == null ? 'All Cities' : 'Select city',
                          items: _filterState == null
                              ? const ['All Cities']
                              : ['All Cities', ...IndiaLocations.getCities(_filterState!)],
                          onChanged: _filterState == null
                              ? null
                              : (value) async {
                                  setState(() {
                                    _filterCity = value == 'All Cities' ? null : value;
                                  });
                                  await ref.read(brandProvider.notifier).fetchDiscovery(
                                        stateFilter: _filterState,
                                        cityFilter: _filterCity,
                                      );
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (brandState.isDiscoveryLoading || brandState.isLoading)
                    Column(
                      children: List.generate(
                        4,
                        (index) => const Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                          child: CreatorCardSkeleton(),
                        ),
                      ),
                    )
                  else if (creators.isEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.huge),
                      child: Text(
                        'No creators match these filters.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMD
                            .copyWith(color: AppColors.muted),
                      ),
                    )
                  else
                    Column(
                      children: creators
                          .map(
                            (creator) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: CreatorCard(
                                creator: creator,
                                onTap: () => _openCreatorDetails(creator),
                                onSendRequest: () =>
                                    _openCreatorDetails(creator),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CreatorPreview> _filteredCreators(List<CreatorPreview> creators) {
    final query = _searchController.text.trim().toLowerCase();

    return creators.where((creator) {
      final nicheMatch = _activeNiche == 'All' ||
          creator.niches
              .map((item) => item.toLowerCase())
              .contains(_activeNiche.toLowerCase());

      if (!nicheMatch) return false;

      if (_selectedTiers.isNotEmpty &&
          !_selectedTiers
              .map((tier) => tier.toLowerCase())
              .contains(creator.tier.toLowerCase())) {
        return false;
      }

      if (_maxBudget != null && creator.startingPrice > _maxBudget!) {
        return false;
      }

      if (_minEngagement != null && creator.engagementRate < _minEngagement!) {
        return false;
      }

      final platformMatch = switch (_platform) {
        'Instagram' => creator.contentTypes.any(
            (item) =>
                item.toLowerCase().contains('instagram') ||
                item.toLowerCase().contains('reel') ||
                item.toLowerCase().contains('story'),
          ),
        'YouTube' => creator.contentTypes.any((item) =>
            item.toLowerCase().contains('youtube') ||
            item.toLowerCase().contains('yt') ||
            item.toLowerCase().contains('short')),
        _ => true,
      };

      if (!platformMatch) return false;

      if (query.isEmpty) return true;
      final creatorText = [
        creator.firstName,
        ...creator.niches,
      ].join(' ').toLowerCase();
      return creatorText.contains(query);
    }).toList();
  }

  Future<void> _openCreatorDetails(CreatorPreview creator) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatorDetailBottomSheet(creator: creator),
    );
  }

  Future<void> _openFilterBottomSheet() async {
    final maxBudgetController = TextEditingController(
      text: _maxBudget?.toString() ?? '',
    );
    final minEngagementController = TextEditingController(
      text: _minEngagement?.toStringAsFixed(1) ?? '',
    );

    final workingTiers = Set<String>.from(_selectedTiers);
    var workingPlatform = _platform;

    await showModalBottomSheet<void>(
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
                  top: Radius.circular(AppSpacing.radiusLG),
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
                        const Text('Filters', style: AppTypography.displaySM),
                        const SizedBox(height: AppSpacing.lg),
                        const Text('Tier', style: AppTypography.labelMD),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: _tiers
                              .map(
                                (tier) => _pill(
                                  label: tier,
                                  active: workingTiers.contains(tier),
                                  onTap: () {
                                    setSheetState(() {
                                      if (workingTiers.contains(tier)) {
                                        workingTiers.remove(tier);
                                      } else {
                                        workingTiers.add(tier);
                                      }
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        BCTextField(
                          label: 'Max Budget (₹)',
                          hint: '5000',
                          keyboardType: TextInputType.number,
                          controller: maxBudgetController,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text('Platform', style: AppTypography.labelMD),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: _platforms
                              .map(
                                (platform) => _pill(
                                  label: platform,
                                  active: workingPlatform == platform,
                                  onTap: () {
                                    setSheetState(
                                        () => workingPlatform = platform);
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        BCTextField(
                          label: 'Min Engagement Rate (%)',
                          hint: '3.5',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          controller: minEngagementController,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        BCPrimaryButton.neon(
                          label: 'Apply →',
                          onPressed: () {
                            setState(() {
                              _selectedTiers
                                ..clear()
                                ..addAll(workingTiers);
                              _maxBudget =
                                  int.tryParse(maxBudgetController.text.trim());
                              _platform = workingPlatform;
                              _minEngagement = double.tryParse(
                                  minEngagementController.text.trim());
                            });
                            Navigator.of(context).pop();
                          },
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
    );

    maxBudgetController.dispose();
    minEngagementController.dispose();
  }

  Widget _pill({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 36),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: active ? AppColors.neon : AppColors.ink,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

const _niches = [
  'All',
  'Fashion',
  'Fitness',
  'Food',
  'Tech',
  'Beauty',
  'Travel',
  'Comedy',
];

const _tiers = ['Nano', 'Micro', 'Mid', 'Macro'];
const _platforms = ['Instagram', 'YouTube', 'Both'];
