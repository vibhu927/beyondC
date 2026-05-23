import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/india_locations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/brand_page_top_header.dart';
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
  static final BorderRadius _pillFieldRadius =
      BorderRadius.circular(AppSpacing.radiusFull);

  final _searchController = TextEditingController();
  String _activeNiche = 'All';
  String? _filterState;
  String? _filterCity;

  final Set<String> _selectedTiers = <String>{};
  int? _maxBudget;
  String _platform = 'Both';
  double? _minEngagement;
  final _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (mounted) setState(() => _scrollOffset = _scrollController.offset);
    });
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandState = ref.watch(brandProvider);
    final creators = _filteredCreators(brandState.creators);
    final topInset = MediaQuery.of(context).padding.top + 14;
    const headerHeight = 48.0;
    const headerGap = 34.0;
    final sheetTop = topInset + headerHeight + headerGap;
    final headerSlide = _scrollOffset.clamp(0.0, sheetTop);
    final collapseProgress =
        (headerSlide / (headerHeight + headerGap)).clamp(0.0, 1.0);
    final collapsedTop = MediaQuery.of(context).padding.top + 8;
    final headerTop = lerpDouble(topInset, collapsedTop, collapseProgress)!;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: FloatingActionButton(
          heroTag: 'creatorDiscoveryFiltersFab',
          onPressed: _openFilterBottomSheet,
          backgroundColor: AppColors.brandDark,
          foregroundColor: AppColors.brandPrimary,
          tooltip: 'Filters',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            side: BorderSide(
              color: AppColors.brandDark.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: const Icon(Icons.tune_rounded),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: AppColors.lightBg),
            ),
          ),
          Positioned(
            top: -46,
            right: -32,
            child: _GlowOrb(
              size: 136,
              color: AppColors.brandPrimary.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            top: 220,
            left: -44,
            child: _GlowOrb(
              size: 112,
              color: AppColors.brandDark.withValues(alpha: 0.08),
            ),
          ),
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              sheetTop + AppSpacing.lg,
              AppSpacing.screenPadding,
              MediaQuery.of(context).padding.bottom + 104,
            ),
            children: [
              Text(
                'Find Creators',
                style: AppTypography.displaySM.copyWith(
                  color: AppColors.brandDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Discover and filter creators that match your campaign goals.',
                style: AppTypography.bodySM.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.lg),
              BCTextField(
                label: 'Search',
                hint: 'Search by niche, name...',
                controller: _searchController,
                borderRadius: _pillFieldRadius,
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
                      borderRadius: _pillFieldRadius,
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
                      borderRadius: _pillFieldRadius,
                      items: _filterState == null
                          ? const ['All Cities']
                          : [
                              'All Cities',
                              ...IndiaLocations.getCities(_filterState!)
                            ],
                      onChanged: _filterState == null
                          ? null
                          : (value) async {
                              setState(() {
                                _filterCity =
                                    value == 'All Cities' ? null : value;
                              });
                              await ref
                                  .read(brandProvider.notifier)
                                  .fetchDiscovery(
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
                    style:
                        AppTypography.bodyMD.copyWith(color: AppColors.muted),
                  ),
                )
              else
                Column(
                  children: creators
                      .map(
                        (creator) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: CreatorCard(
                            creator: creator,
                            onTap: () => _openCreatorDetails(creator),
                            onSendRequest: () => _openCreatorDetails(creator),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: collapsedTop + 48 + 16,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightBg
                      .withValues(alpha: collapseProgress * 0.95),
                  border: collapseProgress > 0.5
                      ? const Border(
                          bottom: BorderSide(color: AppColors.lightBorder))
                      : null,
                ),
              ),
            ),
          ),
          Positioned(
            top: headerTop,
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            child: BrandPageTopHeader(
              showBrandIdentity: false,
              showBackButton: true,
              collapseProgress: collapseProgress,
            ),
          ),
        ],
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
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLG),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
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
                            label: 'Max Budget (INR)',
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
                            label: 'Apply ->',
                            onPressed: () {
                              setState(() {
                                _selectedTiers
                                  ..clear()
                                  ..addAll(workingTiers);
                                _maxBudget = int.tryParse(
                                    maxBudgetController.text.trim());
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
            color: active ? AppColors.brandPrimary : AppColors.ink,
            height: 1,
          ),
          textAlign: TextAlign.center,
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
            BoxShadow(
              color: color,
              blurRadius: size * 0.55,
              spreadRadius: size * 0.04,
            ),
          ],
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
