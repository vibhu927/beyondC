import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'campaign_provider.dart';

class BrandProfile {
  const BrandProfile({
    required this.brandName,
    required this.creditBalance,
    required this.activeCampaignCount,
  });

  final String brandName;
  final int creditBalance;
  final int activeCampaignCount;
}

class CreatorPreview {
  const CreatorPreview({
    required this.id,
    required this.firstName,
    required this.initials,
    required this.tier,
    required this.niches,
    required this.followerRange,
    required this.engagementRate,
    required this.startingPrice,
    required this.bio,
  });

  final String id;
  final String firstName;
  final String initials;
  final String tier;
  final List<String> niches;
  final String followerRange;
  final double engagementRate;
  final int startingPrice;
  final String bio;
}

class BrandCampaignSummary {
  const BrandCampaignSummary({
    required this.id,
    required this.title,
    required this.status,
    required this.bidCount,
    required this.deadline,
  });

  final String id;
  final CampaignStatus status;
  final String title;
  final int bidCount;
  final DateTime deadline;
}

class BrandState {
  const BrandState({
    this.brandProfile,
    this.creditBalance = 0,
    this.activeCampaignCount = 0,
    this.creators = const [],
    this.campaigns = const [],
    this.activeFilter = 'All',
    this.isLoading = false,
    this.error,
  });

  final BrandProfile? brandProfile;
  final int creditBalance;
  final int activeCampaignCount;
  final List<CreatorPreview> creators;
  final List<BrandCampaignSummary> campaigns;
  final String activeFilter;
  final bool isLoading;
  final String? error;

  List<CreatorPreview> get filteredCreators {
    if (activeFilter == 'All') return creators;
    return creators
        .where((creator) => creator.niches.contains(activeFilter))
        .toList();
  }

  BrandState copyWith({
    BrandProfile? brandProfile,
    int? creditBalance,
    int? activeCampaignCount,
    List<CreatorPreview>? creators,
    List<BrandCampaignSummary>? campaigns,
    String? activeFilter,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return BrandState(
      brandProfile: brandProfile ?? this.brandProfile,
      creditBalance: creditBalance ?? this.creditBalance,
      activeCampaignCount: activeCampaignCount ?? this.activeCampaignCount,
      creators: creators ?? this.creators,
      campaigns: campaigns ?? this.campaigns,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

class BrandNotifier extends Notifier<BrandState> {
  @override
  BrandState build() => const BrandState();

  Future<void> fetchBrandHome() async {
    if (state.isLoading || state.brandProfile != null) return;
    await _loadBrandHome();
  }

  Future<void> refreshBrandHome() async {
    await _loadBrandHome();
  }

  void setActiveFilter(String value) {
    state = state.copyWith(activeFilter: value);
  }

  Future<void> _loadBrandHome() async {
    state = state.copyWith(isLoading: true, error: null);

    await Future<void>.delayed(const Duration(seconds: 1));

    final authState = ref.read(authProvider);
    final metadata = authState.user?.userMetadata ?? const <String, dynamic>{};
    final email = authState.user?.email;
    final rawEmailPrefix =
        email != null && email.contains('@') ? email.split('@').first : email;
    final displayName =
        (metadata['display_name'] as String?)?.trim().isNotEmpty == true
            ? (metadata['display_name'] as String).trim()
            : null;
    final firstName =
        (metadata['first_name'] as String?)?.trim().isNotEmpty == true
            ? (metadata['first_name'] as String).trim()
            : null;
    final brandName =
        (metadata['brand_name'] as String?)?.trim().isNotEmpty == true
            ? (metadata['brand_name'] as String).trim()
            : (displayName ?? firstName ?? rawEmailPrefix ?? 'Brand');

    const creditBalance = 15;
    const activeCampaignCount = 4;

    state = state.copyWith(
      isLoading: false,
      brandProfile: BrandProfile(
        brandName: brandName,
        creditBalance: creditBalance,
        activeCampaignCount: activeCampaignCount,
      ),
      creditBalance: creditBalance,
      activeCampaignCount: activeCampaignCount,
      creators: const [
        CreatorPreview(
          id: 'creator-1',
          firstName: 'Priya',
          initials: 'PS',
          tier: 'micro',
          niches: ['Fashion', 'Beauty'],
          followerRange: '18.2K followers',
          engagementRate: 4.3,
          startingPrice: 800,
          bio:
              'Beauty storyteller who turns launches into sharp, polished content.',
        ),
        CreatorPreview(
          id: 'creator-2',
          firstName: 'Rahul',
          initials: 'RM',
          tier: 'mid',
          niches: ['Fitness', 'Health'],
          followerRange: '76K followers',
          engagementRate: 5.1,
          startingPrice: 2400,
          bio:
              'Fitness creator with strong save-rate on routine and supplement content.',
        ),
        CreatorPreview(
          id: 'creator-3',
          firstName: 'Ananya',
          initials: 'AK',
          tier: 'nano',
          niches: ['Food', 'Travel'],
          followerRange: '4.8K followers',
          engagementRate: 6.4,
          startingPrice: 600,
          bio: 'High-conviction food reviews and quick-shot travel edits.',
        ),
        CreatorPreview(
          id: 'creator-4',
          firstName: 'Kabir',
          initials: 'KS',
          tier: 'macro',
          niches: ['Tech'],
          followerRange: '540K followers',
          engagementRate: 3.8,
          startingPrice: 12000,
          bio:
              'Premium tech reviews with launch-day reach and sharp audience trust.',
        ),
        CreatorPreview(
          id: 'creator-5',
          firstName: 'Megha',
          initials: 'MJ',
          tier: 'micro',
          niches: ['Beauty', 'Lifestyle'],
          followerRange: '25K followers',
          engagementRate: 4.9,
          startingPrice: 1400,
          bio: 'Aesthetic daily-life content built for D2C product placement.',
        ),
      ],
      campaigns: [
        BrandCampaignSummary(
          id: 'fit-burst-01',
          title: 'Fitness Sprint Push',
          status: CampaignStatus.active,
          bidCount: 12,
          deadline: DateTime.now().add(const Duration(days: 3)),
        ),
        BrandCampaignSummary(
          id: 'beauty-drop-02',
          title: 'Glow Launch Week',
          status: CampaignStatus.paused,
          bidCount: 7,
          deadline: DateTime.now().add(const Duration(days: 5)),
        ),
        BrandCampaignSummary(
          id: 'event-03',
          title: 'Store Launch Event Push',
          status: CampaignStatus.completed,
          bidCount: 19,
          deadline: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      error: null,
    );
  }
}

const _sentinel = Object();

final brandProvider = NotifierProvider<BrandNotifier, BrandState>(
  BrandNotifier.new,
);
